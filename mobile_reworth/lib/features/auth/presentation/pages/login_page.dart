import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../application/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'demo@reworth.app');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
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
                  'Masuk ke ReWorth',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
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
                      const Text('Login akun Anda', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: AppSpacing.s12),
                      const Text('Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2E5A14))),
                      const SizedBox(height: AppSpacing.s8),
                      _AuthInputField(
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        hint: 'demo@reworth.app',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Username wajib diisi';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      const Text('Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2E5A14))),
                      const SizedBox(height: AppSpacing.s8),
                      _AuthInputField(
                        controller: _passwordController,
                        hint: 'Masukkan kata sandi',
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
                      const SizedBox(height: 26),
                      AppButton(
                        label: 'Login',
                        loading: auth.isLoading,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final result = await ref.read(authControllerProvider).login(
                                email: _usernameController.text,
                                password: _passwordController.text,
                              );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
                          if (result.success) {
                            context.go('/home');
                          }
                        },
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Belum punya akun? Daftar'),
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
      ),
    );
  }
}
