// lib/features/profile/presentation/pages/seller_application_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../market/presentation/pages/seller_registration_page.dart';
import '../../application/profile_controller.dart';
import '../../domain/profile_user.dart';
import '../../domain/seller_application.dart';

class SellerApplicationDetailPage extends ConsumerStatefulWidget {
  const SellerApplicationDetailPage({super.key});

  @override
  ConsumerState<SellerApplicationDetailPage> createState() =>
      _SellerApplicationDetailPageState();
}

class _SellerApplicationDetailPageState
    extends ConsumerState<SellerApplicationDetailPage> {
  bool _isLoading = false;
  SellerApplication? _application;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(profileControllerProvider.notifier).loadProfile();
      await _loadApplicationData();
    });
  }

  Future<void> _loadApplicationData() async {
    print('🟡 Memuat data pengajuan...');
    final controller = ref.read(profileControllerProvider.notifier);
    final application = await controller.getSellerApplicationStatus();
    print('📋 Data pengajuan: ${application?.idPengajuan}');
    if (mounted) {
      setState(() {
        _application = application;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.user;
    final status = user?.statusPengajuanSeller ?? 'nonaktif';

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatusCard(status, user),
                    const SizedBox(height: 20),

                    // Data Pengajuan
                    if (status == 'pending' && _application == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFFB5FF77),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Memuat data pengajuan...',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_application != null)
                      _buildApplicationDataCard(_application!),

                    const SizedBox(height: 24),
                    _buildActionButton(status, user?.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, ProfileUser? user) {
    String title;
    String description;
    IconData icon;
    Color color;

    switch (status) {
      case 'pending':
        title = 'Menunggu Verifikasi';
        description =
            'Pengajuan seller Anda sedang dalam proses verifikasi oleh admin. '
            'Proses ini biasanya memakan waktu 1x24 jam.';
        icon = Icons.pending_actions;
        color = const Color(0xFFFFA726);
        break;
      case 'aktif':
        title = 'Seller Aktif';
        description =
            'Selamat! Akun seller Anda sudah aktif. '
            'Anda sekarang dapat mengelola toko dan produk Anda.';
        icon = Icons.check_circle;
        color = const Color(0xFF4CAF50);
        break;
      case 'ditolak':
        title = 'Pengajuan Ditolak';
        description =
            'Mohon maaf, pengajuan seller Anda ditolak. '
            'Silakan periksa kembali data yang Anda masukkan dan ajukan ulang.';
        icon = Icons.cancel;
        color = const Color(0xFFEF5350);
        break;
      default:
        title = 'Belum Menjadi Seller';
        description =
            'Daftar menjadi seller sekarang dan jual produk daur ulang Anda '
            'di ReWorth Mini Market.';
        icon = Icons.storefront_outlined;
        color = const Color(0xFFB5FF77);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          if (status == 'ditolak')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFEF5350)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admin akan memberikan alasan penolakan melalui email atau notifikasi.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFEF5350),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationDataCard(SellerApplication application) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: Color(0xFFB5FF77),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Data Pengajuan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB5FF77),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Nama Toko', application.namaTokoUsulan),
          if (application.deskripsiToko != null &&
              application.deskripsiToko!.isNotEmpty)
            _buildInfoRow(
              'Deskripsi Toko',
              application.deskripsiToko!,
              isMultiLine: true,
            ),
          if (application.alamatToko != null &&
              application.alamatToko!.isNotEmpty)
            _buildInfoRow(
              'Alamat Toko',
              application.alamatToko!,
              isMultiLine: true,
            ),
          if (application.kategoriJualan != null &&
              application.kategoriJualan!.isNotEmpty)
            _buildInfoRow('Kategori Jualan', application.kategoriJualan!),
          if (application.jenisProdukJualan != null &&
              application.jenisProdukJualan!.isNotEmpty)
            _buildInfoRow('Jenis Produk', application.jenisProdukJualan!),
          _buildInfoRow('Username Dashboard', application.usernameUsulan),
          if (application.tanggalPengajuan != null)
            _buildInfoRow(
              'Tanggal Pengajuan',
              _formatDate(application.tanggalPengajuan!),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          if (isMultiLine) const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildActionButton(String status, String? userId) {
    switch (status) {
      case 'pending':
        return _buildWaitingButton();
      case 'aktif':
        return _buildManageStoreButton();
      case 'ditolak':
        return _buildResubmitButton();
      default:
        return _buildRegisterButton();
    }
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.push('/seller-registration');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Ajukan Menjadi Seller',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildWaitingButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Menunggu Verifikasi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageStoreButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur dashboard seller segera hadir'),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Kelola Toko',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildResubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.push('/seller-registration');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Ajukan Ulang',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ============ HEADER WIDGET ============

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Text(
            'Pengajuan Seller',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
