import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/report_controller.dart';
import '../../domain/report.dart';
import '../../domain/waste_type.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';

class ReportHistoryPage extends ConsumerStatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  ConsumerState<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends ConsumerState<ReportHistoryPage> {
  @override
  void initState() {
    super.initState();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat Lapor Sampah',
          style: AppTypography.h2.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
            ),
            child: const TabBar(
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
        ),
      ),
      body: reportState.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              children: [
                _buildReportList(
                  reportController,
                  'aktif',
                ),
                _buildReportList(
                  reportController,
                  'selesai',
                ),
                _buildReportList(
                  reportController,
                  'ditolak',
                ),
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
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Belum ada laporan $status',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            TextButton.icon(
              onPressed: () => controller.loadReportHistory(),
              icon: const Icon(Icons.refresh, size: 16, color: Colors.green),
              label: Text(
                'Refresh',
                style: AppTypography.button.copyWith(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => controller.loadReportHistory(),
      color: Colors.green,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(report, status);
        },
      ),
    );
  }

  Widget _buildReportCard(Report report, String status) {
    final isRejected = status == 'ditolak';
    final isCompleted = status == 'selesai';
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.r16),
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
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.r16),
                topRight: Radius.circular(AppRadius.r16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getWasteTypeColor(report.wasteType),
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: Text(
                    'Laporan Sampah - ${report.wasteType.label}',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
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
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.s4),
                    Expanded(
                      child: Text(
                        report.street,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.s4),
                    Text(
                      _getTimeAgo(report.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                
                // Progress Steps (4 langkah)
                _buildProgressSteps(report, isCompleted: isCompleted, isRejected: isRejected),
                
                const SizedBox(height: AppSpacing.s16),
                
                // Alasan Penolakan (khusus status ditolak)
                if (isRejected && report.rejectionReason != null)
                  _buildRejectionReason(report.rejectionReason!),
                
                const SizedBox(height: AppSpacing.s8),
                
                // Tombol Lihat Detail
                TextButton(
                  onPressed: () {
                    _showDetailDialog(report, status);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lihat Detail →',
                    style: AppTypography.button.copyWith(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Progress Steps dengan 4 langkah
  Widget _buildProgressSteps(Report report, {required bool isCompleted, required bool isRejected}) {
    final steps = [
      {'label': 'Lapor', 'subtitle': 'Laporan Berhasil Dikirim', 'icon': Icons.send},
      {'label': 'Tunggu', 'subtitle': 'Menunggu Penanganan', 'icon': Icons.hourglass_empty},
      {'label': 'Verifikasi', 'subtitle': 'Selesai Diperiksa', 'icon': Icons.verified},
      {'label': isRejected ? 'Ditolak' : '+10 Poin', 
       'subtitle': isRejected ? 'Laporan Ditolak' : 'Laporan Valid', 
       'icon': isRejected ? Icons.cancel : Icons.star},
    ];

    int currentStep;
    if (isRejected) {
      currentStep = 4;
    } else if (isCompleted) {
      currentStep = 4;
    } else {
      currentStep = 2;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;
          final isRejectedStep = isRejected && step['label'] == 'Ditolak';
          
          return Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? (isRejectedStep ? Colors.red : Colors.green)
                        : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['label'] as String,
                  style: AppTypography.caption.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive 
                        ? (isRejectedStep ? Colors.red : Colors.green)
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  step['subtitle'] as String,
                  style: AppTypography.caption.copyWith(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Widget untuk menampilkan alasan penolakan
  Widget _buildRejectionReason(String reason) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 16),
              const SizedBox(width: AppSpacing.s4),
              Text(
                'Alasan ditolak oleh petugas :',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            reason,
            style: AppTypography.body.copyWith(
              fontSize: 12,
              color: Colors.red.shade900,
              height: 1.4,
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
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

  void _showDetailDialog(Report report, String status) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r16)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: _getWasteTypeColor(report.wasteType),
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan ${report.wasteType.label}',
                          style: AppTypography.title.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          report.id ?? 'ID: -',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.s16),
              _buildDetailRow(Icons.location_on, 'Alamat', report.street),
              const SizedBox(height: AppSpacing.s8),
              _buildDetailRow(Icons.location_city, 'Desa/Kelurahan', report.village),
              const SizedBox(height: AppSpacing.s8),
              _buildDetailRow(Icons.map, 'Kecamatan', report.district),
              const SizedBox(height: AppSpacing.s8),
              _buildDetailRow(Icons.local_post_office_outlined, 'Kode Pos', report.postalCode),
              const SizedBox(height: AppSpacing.s8),
              _buildDetailRow(Icons.description, 'Deskripsi', report.description),
              const SizedBox(height: AppSpacing.s8),
              _buildDetailRow(Icons.category, 'Jenis Sampah', report.wasteType.label),
              const SizedBox(height: AppSpacing.s8),
              _buildDetailRow(Icons.warning, 'Tingkat Keparahan', report.severityLevel.label),
              
              if (status == 'ditolak' && report.rejectionReason != null) ...[
                const SizedBox(height: AppSpacing.s16),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alasan Ditolak',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        report.rejectionReason!,
                        style: AppTypography.body.copyWith(
                          fontSize: 12,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppSpacing.s24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
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
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTypography.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
