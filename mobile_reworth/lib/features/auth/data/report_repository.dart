import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/report_controller.dart';
import '../../domain/waste_type.dart';

class ReportHistoryPage extends ConsumerStatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  ConsumerState<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends ConsumerState<ReportHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load history saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportControllerProvider.notifier).loadReportHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final reportController = ref.read(reportControllerProvider.notifier);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Lapor Sampah'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
              Tab(text: 'Ditolak'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
          ),
        ),
        body: reportState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildReportList(reportController, 'aktif'),
                  _buildReportList(reportController, 'selesai'),
                  _buildReportList(reportController, 'ditolak'),
                ],
              ),
      ),
    );
  }

  Widget _buildReportList(ReportController controller, String status) {
    final reports = controller.getReportsByStatus(status);
    
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada laporan $status',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report, status);
      },
    );
  }

  Widget _buildReportCard(Report report, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getWasteTypeColor(report.wasteType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Laporan Sampah - ${report.wasteType.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
          ),
          
          // Body Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      report.street,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(report.createdAt),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress Steps (hanya untuk status aktif)
                if (status == 'aktif') _buildProgressSteps(),
                
                // Poin (hanya untuk status selesai)
                if (status == 'selesai') _buildPointsCard(),
                
                const SizedBox(height: 12),
                
                // Tombol Lihat Detail
                TextButton(
                  onPressed: () {
                    _showDetailDialog(report);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Lihat Detail →'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStep('Lapor', Icons.send, true),
          _buildStep('Tunggu', Icons.hourglass_empty, false),
          _buildStep('Verifikasi', Icons.verified, false),
        ],
      ),
    );
  }

  Widget _buildStep(String label, IconData icon, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.green : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '+10 Poin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'Poin didapat jika laporan valid',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'aktif':
        color = Colors.blue;
        text = 'Diproses';
        break;
      case 'selesai':
        color = Colors.green;
        text = 'Selesai';
        break;
      case 'ditolak':
        color = Colors.red;
        text = 'Ditolak';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'aktif': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getWasteTypeColor(WasteType type) {
    switch (type) {
      case WasteType.organic:
        return Colors.green;
      case WasteType.inorganic:
        return Colors.blue;
      case WasteType.mixed:
        return Colors.orange;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  void _showDetailDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getWasteTypeColor(report.wasteType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan ${report.wasteType.label}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          report.id ?? 'ID: -',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow(Icons.location_on, 'Alamat', report.street),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.location_city, 'Desa/Kelurahan', report.village),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.map, 'Kecamatan', report.district),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.pin_code, 'Kode Pos', report.postalCode),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.description, 'Deskripsi', report.description),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.category, 'Jenis Sampah', report.wasteType.label),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.warning, 'Tingkat Keparahan', report.severityLevel.label),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}