import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerRegistrationPage extends StatefulWidget {
  const SellerRegistrationPage({super.key});

  @override
  State<SellerRegistrationPage> createState() => _SellerRegistrationPageState();
}

class _SellerRegistrationPageState extends State<SellerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _namaTokoController = TextEditingController();
  final _deskripsiTokoController = TextEditingController();
  final _jenisProdukController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();

  String _kategori = 'Kerajinan Daur Ulang';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHpController.dispose();
    _emailController.dispose();
    _namaTokoController.dispose();
    _deskripsiTokoController.dispose();
    _jenisProdukController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
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
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(
                            0xFFB5FF77,
                          ).withValues(alpha: 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lengkapi data pengajuan seller Anda',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _label('Nama Lengkap'),
                            _input(
                              controller: _namaController,
                              hint: 'Masukkan nama lengkap',
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama wajib diisi';
                                }
                                if (value.trim().length < 3) {
                                  return 'Nama minimal 3 karakter';
                                }
                                return null;
                              },
                            ),
                            _label('Nomor HP'),
                            _input(
                              controller: _nomorHpController,
                              hint: '08xxxxxxxxxx atau +62xxxxxxxxxx',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nomor HP wajib diisi';
                                }
                                final normalized = value
                                    .replaceAll(' ', '')
                                    .replaceAll('-', '');
                                final startsValid =
                                    normalized.startsWith('08') ||
                                    normalized.startsWith('+62');
                                final digitsOnly = normalized.replaceAll(
                                  '+',
                                  '',
                                );
                                final digitsValid = RegExp(
                                  r'^\d+$',
                                ).hasMatch(digitsOnly);
                                if (!startsValid ||
                                    !digitsValid ||
                                    digitsOnly.length < 10 ||
                                    digitsOnly.length > 15) {
                                  return 'Nomor HP tidak valid';
                                }
                                return null;
                              },
                            ),
                            _label('Email'),
                            _input(
                              controller: _emailController,
                              hint: 'nama@email.com',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email wajib diisi';
                                }
                                if (!RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(value.trim())) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                            ),
                            _label('Nama Toko'),
                            _input(
                              controller: _namaTokoController,
                              hint: 'Masukkan nama toko',
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
                              hint: 'Ceritakan produk/keunggulan toko Anda',
                              icon: Icons.description_outlined,
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Deskripsi toko wajib diisi';
                                }
                                return null;
                              },
                            ),
                            _label('Kategori Produk'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _kategori,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF10261B),
                              borderRadius: BorderRadius.circular(16),
                              decoration: _decoration(
                                hint: 'Pilih kategori',
                                icon: Icons.category_outlined,
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              items:
                                  const [
                                        'Kerajinan Daur Ulang',
                                        'Eco Enzyme',
                                        'Kompos',
                                        'Peralatan Ramah Lingkungan',
                                      ]
                                      .map(
                                        (value) => DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _kategori = value);
                                }
                              },
                            ),
                            _label('Jenis Produk yang Dijual'),
                            _input(
                              controller: _jenisProdukController,
                              hint: 'Contoh: Tas daur ulang, kompos organik',
                              icon: Icons.inventory_2_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Jenis produk wajib diisi';
                                }
                                return null;
                              },
                            ),
                            _label('Username Dashboard'),
                            _input(
                              controller: _usernameController,
                              hint: 'Buat username seller',
                              icon: Icons.account_circle_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username wajib diisi';
                                }
                                return null;
                              },
                            ),
                            _label('Kata Sandi Dashboard'),
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
                                  color: Colors.white.withValues(alpha: 0.72),
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
                            _label('Konfirmasi Kata Sandi'),
                            _input(
                              controller: _konfirmasiPasswordController,
                              hint: 'Ulangi kata sandi',
                              icon: Icons.verified_user_outlined,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white.withValues(alpha: 0.72),
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
                                  return 'Konfirmasi password tidak sesuai';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF94FF38,
                                      ).withValues(alpha: 0.24),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFFB5FF77),
                                      Color(0xFF5BE22F),
                                    ],
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: _submit,
                                  child: Text(
                                    'Kirim Pengajuan Seller',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF0A1A12),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFB5FF77),
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
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: const Color(0xFFB5FF77),
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
        color: Colors.white.withValues(alpha: 0.46),
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFB5FF77).withValues(alpha: 0.88),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      constraints: const BoxConstraints(minHeight: 56),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: const Color(0xFFB5FF77).withValues(alpha: 0.22),
          width: 1.4,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: const Color(0xFFB5FF77).withValues(alpha: 0.22),
          width: 1.4,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF94FF38), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF173A2C),
        content: Text(
          'Pengajuan seller berhasil dikirim. Menunggu persetujuan admin.',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
    context.pop();
  }
}

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
