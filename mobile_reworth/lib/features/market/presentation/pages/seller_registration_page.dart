// lib/features/market/presentation/pages/seller_registration_page.dart

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../profile/application/profile_controller.dart';
import '../../../profile/domain/profile_user.dart';
import '../../../profile/domain/seller_application.dart';

// ============ THEME COLORS ============
const Color _primaryColor = Color(0xFF2E7D32);
const Color _primaryLightColor = Color(0xFF4CAF50);
const Color _backgroundColor = Color(0xFF001F1A);
const Color _cardColor = Color(0xFFFFFFFF);
const Color _surfaceColor = Color(0xFFFAFAFA);
const Color _textColor = Color(0xFF1A1A1A);
const Color _textSecondaryColor = Color(0xFF757575);
const Color _borderColor = Color(0xFFE0E0E0);
const Color _errorColor = Color(0xFFEF4444);
const Color _warningColor = Color(0xFFFFA726);
const Color _successColor = Color(0xFF4CAF50);

class SellerRegistrationPage extends ConsumerStatefulWidget {
  const SellerRegistrationPage({super.key});

  @override
  ConsumerState<SellerRegistrationPage> createState() =>
      _SellerRegistrationPageState();
}

class _SellerRegistrationPageState
    extends ConsumerState<SellerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaTokoController = TextEditingController();
  final _deskripsiTokoController = TextEditingController();
  final _alamatTokoController = TextEditingController();
  final _jenisProdukController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();

  String _kategoriJualan = 'Kerajinan Daur Ulang';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  File? _fotoTokoFile;
  File? _fotoProdukFile;

  final ImagePicker _picker = ImagePicker();

  final List<String> _kategoriOptions = [
    'Kerajinan Daur Ulang',
    'Eco Enzyme',
    'Kompos',
    'Peralatan Ramah Lingkungan',
    'Pakaian Bekas',
    'Elektronik Bekas',
    'Mainan Bekas',
    'Buku Bekas',
    'Lainnya',
  ];

  @override
  void dispose() {
    _namaTokoController.dispose();
    _deskripsiTokoController.dispose();
    _alamatTokoController.dispose();
    _jenisProdukController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isFotoToko}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        if (isFotoToko) {
          _fotoTokoFile = File(picked.path);
        } else {
          _fotoProdukFile = File(picked.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.user;

    if (profileState.isLoading) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: _primaryLightColor),
        ),
      );
    }

    final statusPengajuan = user?.statusPengajuanSeller ?? 'nonaktif';

    if (statusPengajuan == 'pending') {
      return _buildPendingPage();
    }

    if (statusPengajuan == 'aktif') {
      return _buildAlreadySellerPage();
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: Column(
              children: [
                _Header(onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoCard(user),
                            const SizedBox(height: 24),
                            const Divider(color: _borderColor, height: 1),
                            const SizedBox(height: 20),

                            _sectionTitle('Informasi Toko'),
                            const SizedBox(height: 12),

                            _label('Nama Toko *'),
                            _input(
                              controller: _namaTokoController,
                              hint: 'Masukkan nama toko Anda',
                              icon: Icons.storefront_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama toko wajib diisi';
                                }
                                return null;
                              },
                            ),

                            _label('Deskripsi Toko'),
                            _input(
                              controller: _deskripsiTokoController,
                              hint: 'Ceritakan produk dan keunggulan toko Anda',
                              icon: Icons.description_outlined,
                              maxLines: 3,
                            ),

                            _label('Alamat Toko'),
                            _input(
                              controller: _alamatTokoController,
                              hint:
                                  'Contoh: Jalan Merdeka No. 10, Kelurahan Sukamaju, Kecamatan Beji, Kota Depok',
                              icon: Icons.location_on_outlined,
                              maxLines: 3,
                            ),

                            _label('Kategori Jualan'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _kategoriJualan,
                              isExpanded: true,
                              dropdownColor: _cardColor,
                              borderRadius: BorderRadius.circular(12),
                              decoration: _decoration(
                                hint: 'Pilih kategori',
                                icon: Icons.category_outlined,
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: _textColor,
                              ),
                              items: _kategoriOptions.map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(
                                      color: _textColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _kategoriJualan = value);
                                }
                              },
                            ),

                            _label('Jenis Produk yang Dijual'),
                            _input(
                              controller: _jenisProdukController,
                              hint:
                                  'Contoh: Tas daur ulang, kompos organik, eco enzyme',
                              icon: Icons.inventory_2_outlined,
                            ),

                            const SizedBox(height: 20),
                            const Divider(color: _borderColor, height: 1),
                            const SizedBox(height: 20),

                            _sectionTitle('Dokumen Pendukung'),
                            const SizedBox(height: 12),

                            _label('Foto Toko (Opsional)'),
                            _buildImagePicker(
                              imageFile: _fotoTokoFile,
                              onTap: () => _pickImage(isFotoToko: true),
                              title: 'Upload Foto Toko',
                            ),

                            const SizedBox(height: 16),

                            _label('Foto Produk Contoh (Opsional)'),
                            _buildImagePicker(
                              imageFile: _fotoProdukFile,
                              onTap: () => _pickImage(isFotoToko: false),
                              title: 'Upload Contoh Produk',
                            ),

                            const SizedBox(height: 20),
                            const Divider(color: _borderColor, height: 1),
                            const SizedBox(height: 20),

                            _sectionTitle('Akun Dashboard Seller'),
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Username dan password ini akan digunakan untuk login ke dashboard seller',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            _label('Username Dashboard *'),
                            _input(
                              controller: _usernameController,
                              hint: 'Buat username untuk login dashboard',
                              icon: Icons.account_circle_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username wajib diisi';
                                }
                                if (value.length < 4) {
                                  return 'Username minimal 4 karakter';
                                }
                                return null;
                              },
                            ),

                            _label('Password Dashboard *'),
                            _input(
                              controller: _passwordController,
                              hint: 'Minimal 8 karakter',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _textSecondaryColor,
                                  size: 21,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password wajib diisi';
                                }
                                if (value.length < 8) {
                                  return 'Password minimal 8 karakter';
                                }
                                return null;
                              },
                            ),

                            _label('Konfirmasi Password *'),
                            _input(
                              controller: _konfirmasiPasswordController,
                              hint: 'Ulangi password',
                              icon: Icons.verified_user_outlined,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _textSecondaryColor,
                                  size: 21,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Konfirmasi password wajib diisi';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password tidak sesuai';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _submit(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Ajukan Menjadi Seller',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildImagePicker({
    required File? imageFile,
    required VoidCallback onTap,
    required String title,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: imageFile != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(imageFile, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: onTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: _primaryColor.withValues(alpha: 0.6),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _infoCard(ProfileUser? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryLightColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryLightColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _primaryLightColor.withValues(alpha: 0.15),
            child: Text(
              user?.nama.isNotEmpty == true ? user!.nama[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nama ?? 'Memuat...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '-',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textSecondaryColor,
                  ),
                ),
                Text(
                  user?.noTelp ?? '-',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _primaryLightColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(user?.statusPengajuanSeller),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Pengajuan Diproses';
      case 'aktif':
        return 'Seller Aktif';
      case 'ditolak':
        return 'Ditolak';
      case 'nonaktif':
        return 'Belum Daftar';
      default:
        return 'Belum Daftar';
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _primaryColor,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: _textColor.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: _textColor,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: _primaryColor,
      decoration: _decoration(hint: hint, icon: icon, suffixIcon: suffixIcon),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: _textSecondaryColor.withValues(alpha: 0.7),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: _primaryColor.withValues(alpha: 0.7),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _errorColor, width: 1),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    print('🔵 SUBMIT: Form divalidasi...');

    if (!_formKey.currentState!.validate()) {
      print('❌ SUBMIT: Form tidak valid');
      return;
    }

    print('✅ SUBMIT: Form valid');
    print('📝 Data:');
    print('   - Nama Toko: ${_namaTokoController.text.trim()}');
    print('   - Username: ${_usernameController.text.trim()}');

    setState(() => _isSubmitting = true);

    try {
      final profileController = ref.read(profileControllerProvider.notifier);

      String? fotoTokoUrl;
      String? fotoProdukUrl;

      if (_fotoTokoFile != null) {
        print('🟡 Upload foto toko...');
        fotoTokoUrl = await profileController.uploadSellerPhoto(
          _fotoTokoFile!,
          'foto_toko',
        );
        print('   Foto Toko URL: $fotoTokoUrl');
      }

      if (_fotoProdukFile != null) {
        print('🟡 Upload foto produk...');
        fotoProdukUrl = await profileController.uploadSellerPhoto(
          _fotoProdukFile!,
          'foto_produk',
        );
        print('   Foto Produk URL: $fotoProdukUrl');
      }

      print('🟡 Memanggil submitSellerApplication...');

      final success = await profileController.submitSellerApplication(
        namaTokoUsulan: _namaTokoController.text.trim(),
        deskripsiToko: _deskripsiTokoController.text.trim().isEmpty
            ? null
            : _deskripsiTokoController.text.trim(),
        alamatToko: _alamatTokoController.text.trim().isEmpty
            ? null
            : _alamatTokoController.text.trim(),
        kategoriJualan: _kategoriJualan,
        jenisProdukJualan: _jenisProdukController.text.trim().isEmpty
            ? null
            : _jenisProdukController.text.trim(),
        usernameUsulan: _usernameController.text.trim(),
        passwordHashUsulan: _passwordController.text,
        fotoToko: fotoTokoUrl,
        fotoProdukContoh: fotoProdukUrl,
      );

      print('📊 Hasil success = $success');

      if (success && mounted) {
        print('✅ Berhasil!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _primaryColor,
            content: Text(
              'Pengajuan seller berhasil dikirim! Menunggu persetujuan admin.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
        context.pop();
      } else if (mounted) {
        print('❌ Gagal, success = false');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: _errorColor,
            content: Text('Gagal mengirim pengajuan. Silakan coba lagi.'),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERROR: $e');
      print('📚 Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _errorColor,
            content: Text('Error: ${e.toString().substring(0, 100)}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      print('🏁 Submit selesai');
    }
  }

  Widget _buildPendingPage() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => context.pop()),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _warningColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.pending_actions,
                          size: 64,
                          color: _warningColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Menunggu Verifikasi',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pengajuan seller Anda sedang dalam proses verifikasi oleh admin',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // HANYA TOMBOL KEMBALI (tanpa tombol batalkan)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Kembali',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadySellerPage() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => context.pop()),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _successColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 64,
                          color: _successColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Anda Sudah Menjadi Seller!',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Selamat! Akun seller Anda sudah aktif.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Kembali',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ HELPER WIDGETS ============

class _Backdrop extends StatelessWidget {
  const _Backdrop();

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
          top: -140,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFB5FF77).withValues(alpha: 0.34),
                      const Color(0xFF5BE22F).withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
            'Registrasi Seller',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
