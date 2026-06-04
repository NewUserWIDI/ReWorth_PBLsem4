import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../profile/application/profile_controller.dart';
import '../../../profile/domain/profile_user.dart';
import '../../../profile/domain/seller_application.dart';

// ============ THEME COLORS ============
const Color _primaryColor = Color(0xFF4CAF50); // Hijau terang untuk tombol
const Color _primaryDarkColor = Color(0xFF2E7D32); // Hijau tua
const Color _backgroundColor = Color(
  0xFF001F1A,
); // Background gelap kehijauan (original)
const Color _cardColor = Color(
  0xFF0D2A22,
); // Card gelap kehijauan (lebih terang dari bg)
const Color _surfaceColor = Color(0xFF1A3A30); // Surface input field
const Color _textColor = Color(0xFFFFFFFF); // PUTIH untuk text utama
const Color _textSecondaryColor = Color(0xFFB0C4B0); // Abu-abu kehijauan terang
const Color _borderColor = Color(0xFF2A4A3E); // Border hijau gelap
const Color _errorColor = Color(0xFFEF4444); // Merah error
const Color _warningColor = Color(0xFFFFA726); // Oranye warning
const Color _successColor = Color(0xFF4CAF50); // Hijau sukses

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
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pengajuan Seller',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Info User Card
            _infoCard(user),
            const SizedBox(height: 16),

            // Form Card
            Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Toko
                    _sectionTitle('Informasi Toko'),

                    _inputField(
                      controller: _namaTokoController,
                      label: 'Nama Toko',
                      hint: 'Masukkan nama toko Anda',
                      icon: Icons.storefront_outlined,
                      isRequired: true,
                    ),

                    _inputField(
                      controller: _deskripsiTokoController,
                      label: 'Deskripsi Toko',
                      hint: 'Ceritakan produk dan keunggulan toko Anda',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),

                    _inputField(
                      controller: _alamatTokoController,
                      label: 'Alamat Toko',
                      hint: 'Jalan, Kelurahan, Kecamatan, Kota',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),

                    _dropdownField(
                      label: 'Kategori Jualan',
                      value: _kategoriJualan,
                      items: _kategoriOptions,
                      icon: Icons.category_outlined,
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _kategoriJualan = value);
                      },
                    ),

                    _inputField(
                      controller: _jenisProdukController,
                      label: 'Jenis Produk',
                      hint: 'Contoh: Tas daur ulang, kompos organik',
                      icon: Icons.inventory_2_outlined,
                    ),

                    // Divider
                    Divider(height: 32, color: _borderColor),

                    // Dokumen Pendukung
                    _sectionTitle('Dokumen Pendukung'),

                    _imagePickerField(
                      label: 'Foto Toko (Opsional)',
                      imageFile: _fotoTokoFile,
                      onTap: () => _pickImage(isFotoToko: true),
                    ),

                    _imagePickerField(
                      label: 'Foto Produk (Opsional)',
                      imageFile: _fotoProdukFile,
                      onTap: () => _pickImage(isFotoToko: false),
                    ),

                    // Divider
                    Divider(height: 32, color: _borderColor),

                    // Akun Dashboard
                    _sectionTitle('Akun Dashboard Seller'),

                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Username dan password untuk login ke dashboard seller',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.blue.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _inputField(
                      controller: _usernameController,
                      label: 'Username Dashboard',
                      hint: 'Buat username untuk login dashboard',
                      icon: Icons.account_circle_outlined,
                      isRequired: true,
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

                    _inputField(
                      controller: _passwordController,
                      label: 'Password Dashboard',
                      hint: 'Minimal 8 karakter',
                      icon: Icons.lock_outline_rounded,
                      isRequired: true,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _textSecondaryColor,
                          size: 20,
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

                    _inputField(
                      controller: _konfirmasiPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Ulangi password',
                      icon: Icons.verified_user_outlined,
                      isRequired: true,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _textSecondaryColor,
                          size: 20,
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ WIDGETS ============

  Widget _infoCard(ProfileUser? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: _primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nama ?? 'Memuat...',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _warningColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(user?.statusPengajuanSeller),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _warningColor,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textSecondaryColor,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _errorColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator:
                validator ??
                (isRequired
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '$label tidak boleh kosong';
                        }
                        return null;
                      }
                    : null),
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _textColor,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: _primaryColor,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: _textSecondaryColor.withValues(alpha: 0.5),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: _textSecondaryColor, size: 20),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: _surfaceColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryColor, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textSecondaryColor,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            dropdownColor: _surfaceColor, // Warna dropdown item gelap
            borderRadius: BorderRadius.circular(12),
            icon: Icon(Icons.arrow_drop_down, color: _textSecondaryColor),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _textColor,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _textSecondaryColor, size: 20),
              filled: true,
              fillColor:
                  _surfaceColor, // Background dropdown tertutup jadi gelap
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryColor, width: 1),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(fontSize: 14, color: _textColor),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _imagePickerField({
    required String label,
    required File? imageFile,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textSecondaryColor,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 100,
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
                          color: _textSecondaryColor,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload Foto',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _textSecondaryColor,
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final profileController = ref.read(profileControllerProvider.notifier);

      String? fotoTokoUrl;
      String? fotoProdukUrl;

      if (_fotoTokoFile != null) {
        fotoTokoUrl = await profileController.uploadSellerPhoto(
          _fotoTokoFile!,
          'foto_toko',
        );
      }

      if (_fotoProdukFile != null) {
        fotoProdukUrl = await profileController.uploadSellerPhoto(
          _fotoProdukFile!,
          'foto_produk',
        );
      }

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

      if (success && mounted) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: _errorColor,
            content: Text('Gagal mengirim pengajuan. Silakan coba lagi.'),
          ),
        );
      }
    } catch (e) {
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
    }
  }

  Widget _buildPendingPage() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pengajuan Seller',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _warningColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pending_actions,
                  size: 48,
                  color: _warningColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Menunggu Verifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
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
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildAlreadySellerPage() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pengajuan Seller',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _successColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, size: 48, color: _successColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Anda Sudah Menjadi Seller!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
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
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
}
