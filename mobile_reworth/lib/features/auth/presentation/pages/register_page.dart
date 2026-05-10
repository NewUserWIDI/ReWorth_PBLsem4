import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            height: 164,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2F6510),
                  Color(0xFF3B6D11),
                  Color(0xFF4E8F1D),
                  Color(0xFFB5FF77),
                ],
                stops: [0.0, 0.66, 0.88, 1.0],
              ),
            ),
            child: const SafeArea(
              bottom: false,
              child: Center(
                child: Text(
                  'Registrasi',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Selamat Datang di ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                            TextSpan(text: 'REWORTH', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Yuk kumpulkan nilai dari setiap aksi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 24),
                      _sectionLabel('Nama'),
                      const SizedBox(height: AppSpacing.s8),
                      _AuthInputField(
                        controller: _namaController,
                        hint: '',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                          if (value.trim().length < 3) return 'Nama minimal 3 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _sectionLabel('No.Telepon'),
                      const SizedBox(height: AppSpacing.s8),
                      _AuthInputField(
                        controller: _nomorHpController,
                        hint: '',
                        prefixIcon: Icons.phone,
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
                      const SizedBox(height: AppSpacing.s12),
                      _sectionLabel('Email'),
                      const SizedBox(height: AppSpacing.s8),
                      _AuthInputField(
                        controller: _emailController,
                        hint: '',
                        prefixIcon: Icons.email_outlined,
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
                      const SizedBox(height: AppSpacing.s12),
                      _sectionLabel('Kata Sandi'),
                      const SizedBox(height: AppSpacing.s8),
                      _AuthInputField(
                        controller: _passwordController,
                        hint: '',
                        prefixIcon: Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF355F1C)),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password wajib diisi';
                          if (value.length < 8) return 'Password minimal 8 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 34),
                      AppButton(
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
                          if (result.success) context.go('/home');
                        },
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sudah punya akun? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2D5A14),
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
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF355F1C)),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
