import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/auth_header_sheet_layout.dart';
import '../../application/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureKonfirmasiPassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthHeaderSheetLayout(
      title: 'Daftar Akun',
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lengkapi data diri Anda',
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromRGBO(17, 17, 17, 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Nama Lengkap'),
              const SizedBox(height: 10),
              _AuthInputField(
                controller: _namaController,
                hint: 'Masukkan nama lengkap',
                prefixIcon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                  if (value.trim().length < 3) return 'Nama minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Nomor HP'),
              const SizedBox(height: 10),
              _AuthInputField(
                controller: _nomorHpController,
                hint: '08xxxxxxxxxx atau +62xxxxxxxxxx',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Nomor HP wajib diisi';
                  final normalized = value.replaceAll(' ', '').replaceAll('-', '');
                  final startsValid = normalized.startsWith('08') || normalized.startsWith('+62');
                  final digitsOnly = normalized.replaceAll('+', '');
                  final digitsValid = RegExp(r'^\d+$').hasMatch(digitsOnly);
                  if (!startsValid || !digitsValid || digitsOnly.length < 10 || digitsOnly.length > 15) {
                    return 'Nomor HP tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Email'),
              const SizedBox(height: 10),
              _AuthInputField(
                controller: _emailController,
                hint: 'nama@email.com',
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                  final email = value.trim();
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Kata Sandi'),
              const SizedBox(height: 10),
              _AuthInputField(
                controller: _passwordController,
                hint: 'Minimal 8 karakter',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color.fromRGBO(17, 17, 17, 0.72),
                    size: 21,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password wajib diisi';
                  if (value.length < 8) return 'Password minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Konfirmasi Kata Sandi'),
              const SizedBox(height: 10),
              _AuthInputField(
                controller: _konfirmasiPasswordController,
                hint: 'Ulangi kata sandi',
                prefixIcon: Icons.verified_user_outlined,
                obscureText: _obscureKonfirmasiPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureKonfirmasiPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color.fromRGBO(17, 17, 17, 0.72),
                    size: 21,
                  ),
                  onPressed: () => setState(() => _obscureKonfirmasiPassword = !_obscureKonfirmasiPassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                  if (value != _passwordController.text) return 'Konfirmasi password tidak sesuai';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              _AuthGradientButton(
                label: 'Daftar',
                loading: auth.isLoading,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final result = await ref.read(authControllerProvider).register(
                        nama: _namaController.text,
                        nomorHp: _nomorHpController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
                  if (result.success) {
                    context.go('/home');
                  }
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.43,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(17, 17, 17, 0.55),
                          ),
                        ),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.43,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
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
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.46,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E7D32),
      ),
    );
  }
}

class _AuthInputField extends StatelessWidget {
  const _AuthInputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 16,
        height: 1.4,
        color: Color(0xFF111111),
        fontWeight: FontWeight.w500,
      ),
      cursorColor: const Color(0xFF2E7D32),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color.fromRGBO(17, 17, 17, 0.45),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color.fromRGBO(17, 17, 17, 0.72),
          size: 21,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        constraints: const BoxConstraints(minHeight: 58),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color.fromRGBO(46, 125, 50, 0.28),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color.fromRGBO(46, 125, 50, 0.28),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF5BBF3D),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _AuthGradientButton extends StatelessWidget {
  const _AuthGradientButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F5E23).withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1F5E23), Color(0xFF2E7D32)],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: loading ? null : onPressed,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(255, 255, 255, 0.08),
                          Color.fromRGBO(255, 255, 255, 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            height: 1.41,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

