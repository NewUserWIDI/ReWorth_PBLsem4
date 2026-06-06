import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../application/report_controller.dart';
import '../../domain/report.dart';
import '../../domain/waste_type.dart';

// Enum untuk tab status
enum _ReportTab { active, completed, rejected }

class ReportHistoryPage extends ConsumerStatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  ConsumerState<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends ConsumerState<ReportHistoryPage> {
  _ReportTab _selectedTab = _ReportTab.active;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(reportControllerProvider.notifier).loadReportHistory();
      }
    });
  }

  void _goBack() {
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final reportController = ref.read(reportControllerProvider.notifier);

    final reports = _getFilteredReports(reportController);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradien premium
          const _PremiumBackdrop(),
          // Konten utama
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: IconButton(
                          onPressed: _goBack,
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Riwayat Lapor Sampah',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom Tab Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _buildCustomTabBar(),
                ),
                // Konten utama scrollable
                Expanded(
                  child: reportState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8EEA5B),
                          ),
                        )
                      : _buildReportList(reportController, reports),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          _buildTabButton(label: 'Aktif', tab: _ReportTab.active),
          _buildTabButton(label: 'Selesai', tab: _ReportTab.completed),
          _buildTabButton(label: 'Ditolak', tab: _ReportTab.rejected),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String label, required _ReportTab tab}) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? const Color(0xFF082018)
                  : Colors.white.withOpacity(0.72),
            ),
          ),
        ),
      ),
    );
  }

  List<Report> _getFilteredReports(ReportController controller) {
    switch (_selectedTab) {
      case _ReportTab.active:
        return controller.getReportsByStatus('aktif');
      case _ReportTab.completed:
        return controller.getReportsByStatus('selesai');
      case _ReportTab.rejected:
        return controller.getReportsByStatus('ditolak');
    }
  }

  Widget _buildReportList(ReportController controller, List<Report> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 40,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                if (mounted) {
                  controller.loadReportHistory();
                }
              },
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: Color(0xFF8EEA5B),
              ),
              label: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8EEA5B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (mounted) {
          await controller.loadReportHistory();
        }
      },
      color: const Color(0xFF8EEA5B),
      backgroundColor: const Color(0xFF003B2F),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedTab) {
      case _ReportTab.active:
        return 'Belum ada laporan aktif\nLaporan yang sedang diproses akan muncul di sini';
      case _ReportTab.completed:
        return 'Belum ada laporan selesai\nLaporan yang sudah selesai akan muncul di sini';
      case _ReportTab.rejected:
        return 'Belum ada laporan ditolak\nLaporan yang ditolak akan muncul di sini';
    }
  }

  // ========== CARD LAPORAN ==========
  Widget _buildReportCard(Report report) {
    final isRejected = report.status == 'rejected';
    final isActive =
        report.status == 'pending' || report.status == 'processing';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withOpacity(0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getWasteTypeColor(
                      report.wasteType,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getWasteTypeIcon(report.wasteType),
                    color: _getWasteTypeColor(report.wasteType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${report.wasteType.label}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${report.street}, ${report.village}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: report.statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: report.statusColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    report.statusDisplayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: report.statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // DIVIDER
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withOpacity(0.05),
          ),
          // BODY CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(report.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    if (report.poinDiberikan > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: const Color(0xFF8EEA5B).withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${report.poinDiberikan} Poin',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8EEA5B),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (report.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      report.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (isRejected && report.alasanDitolak != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            report.alasanDitolak!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildProgressIndicator(report),
                  ),
                // TOMBOL LIHAT DETAIL LENGKAP
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(
                    onPressed: () => _showDetailDialog(report),
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Detail Lengkap',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF082018),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFF082018),
                        ),
                      ],
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

  Widget _buildProgressIndicator(Report report) {
    int currentStep;
    switch (report.status) {
      case 'pending':
        currentStep = 1;
        break;
      case 'processing':
        currentStep = 2;
        break;
      case 'completed':
        currentStep = 3;
        break;
      default:
        currentStep = 1;
    }

    final steps = [
      {'label': 'Lapor', 'icon': Icons.send},
      {'label': 'Proses', 'icon': Icons.hourglass_empty},
      {'label': 'Selesai', 'icon': Icons.verified},
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index < currentStep;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF8DCB94)
                          : Colors.white.withOpacity(0.1),
                    ),
                    child: Icon(
                      steps[index]['icon'] as IconData,
                      size: 14,
                      color: isActive
                          ? const Color(0xFF082018)
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: (index + 1) < currentStep
                        ? const Color(0xFF8DCB94)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  String _getProgressText(String? status) {
    switch (status) {
      case 'pending':
        return 'Menunggu verifikasi petugas';
      case 'processing':
        return 'Sedang diproses oleh petugas';
      case 'completed':
        return 'Laporan telah selesai diproses';
      default:
        return 'Status tidak diketahui';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  IconData _getWasteTypeIcon(WasteType type) {
    switch (type) {
      case WasteType.organic:
        return Icons.eco;
      case WasteType.inorganic:
        return Icons.recycling;
      case WasteType.b3:
        return Icons.warning_amber_rounded;
      case WasteType.mixed:
        return Icons.delete_sweep;
    }
  }

  Color _getWasteTypeColor(WasteType type) {
    switch (type) {
      case WasteType.organic:
        return const Color(0xFF4CAF50);
      case WasteType.inorganic:
        return const Color(0xFF2196F3);
      case WasteType.b3:
        return const Color(0xFFF44336);
      case WasteType.mixed:
        return const Color(0xFFFF9800);
    }
  }

  void _showDetailDialog(Report report) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF001F1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: report.imagePath.isNotEmpty
                          ? () =>
                                _showFullImage(report.imagePath, dialogContext)
                          : null,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          image: report.imagePath.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(report.imagePath),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: report.imagePath.isEmpty
                            ? Icon(
                                Icons.image_not_supported,
                                color: Colors.white.withOpacity(0.5),
                                size: 30,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan ${report.wasteType.label}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: report.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report.statusDisplayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: report.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Colors.white12),

                if (report.imagePath.isNotEmpty) ...[
                  const Text(
                    'Foto Sampah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        _showFullImage(report.imagePath, dialogContext),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        report.imagePath,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.white.withOpacity(0.05),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.white.withOpacity(0.05),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF8EEA5B),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildDetailRow(
                  Icons.location_on,
                  'Alamat Lengkap',
                  '${report.street}, ${report.village}, ${report.district}',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.description,
                  'Deskripsi',
                  report.description.isEmpty
                      ? 'Tidak ada deskripsi'
                      : report.description,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.category,
                  'Jenis Sampah',
                  report.wasteType.label,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.warning,
                  'Tingkat Keparahan',
                  report.severityLevel.label,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.access_time,
                  'Waktu Lapor',
                  '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year} ${report.createdAt.hour.toString().padLeft(2, '0')}:${report.createdAt.minute.toString().padLeft(2, '0')}',
                ),

                if (report.poinDiberikan > 0) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.star,
                    'Poin Diberikan',
                    '+${report.poinDiberikan} Poin',
                    valueColor: const Color(0xFF8EEA5B),
                  ),
                ],

                if (report.alasanDitolak != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Colors.red.withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Alasan Ditolak',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.alasanDitolak!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    if (report.imagePath.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8DCB94), Color(0xFF4D8E63)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                _showFullImage(report.imagePath, dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFF082018),
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Full Foto',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF082018),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl, BuildContext dialogContext) {
    if (!mounted) return;

    showDialog(
      context: dialogContext,
      barrierDismissible: true,
      builder: (fullImageContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 60,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Gagal memuat gambar',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(fullImageContext),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget PremiumBackdrop
class _PremiumBackdrop extends StatelessWidget {
  const _PremiumBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF003B2F), Color(0xFF002D24), Color(0xFF001F1A)],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 135, sigmaY: 135),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB7F164).withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
