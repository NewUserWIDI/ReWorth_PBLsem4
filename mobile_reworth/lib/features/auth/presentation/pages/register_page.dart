import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/auth_controller.dart';
import '../widgets/premium_auth_widgets.dart';

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
  bool _acceptTerms = false;

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
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 370;

    return Scaffold(
      backgroundColor: const Color(0xFF020705),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PremiumAuthBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    34,
                    24,
                    34 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 68,
                    ),
                    child: Center(
                      child: GlassAuthCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Daftar ke ReWorth',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: compact ? 25 : 28,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Buat akun baru Anda',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  height: 1.45,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.68),
                                ),
                              ),
                              const SizedBox(height: 28),
                              GlassTextField(
                                controller: _namaController,
                                hintText: 'Nama lengkap',
                                icon: Icons.person_outline_rounded,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
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
                              const SizedBox(height: 14),
                              GlassTextField(
                                controller: _nomorHpController,
                                hintText: '08xxxxxxxxxx atau +62xxxxxxxxxx',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
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
                              const SizedBox(height: 14),
                              GlassTextField(
                                controller: _emailController,
                                hintText: 'E-mail',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email wajib diisi';
                                  }
                                  final email = value.trim();
                                  if (!RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(email)) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              GlassTextField(
                                controller: _passwordController,
                                hintText: 'Kata sandi',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                suffixIcon: IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFFA8F5B8),
                                    size: 22,
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
                              const SizedBox(height: 14),
                              GlassTextField(
                                controller: _konfirmasiPasswordController,
                                hintText: 'Konfirmasi kata sandi',
                                icon: Icons.verified_user_outlined,
                                obscureText: _obscureKonfirmasiPassword,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    setState(() {
                                      _obscureKonfirmasiPassword =
                                          !_obscureKonfirmasiPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureKonfirmasiPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFFA8F5B8),
                                    size: 22,
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
                              const SizedBox(height: 14),
                              _TermsRow(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                              PrimaryNeonButton(
                                label: 'Buat Akun',
                                loading: auth.isLoading,
                                onPressed: () async {
                                  final isValid =
                                      _formKey.currentState?.validate() ??
                                      false;
                                  if (!isValid) return;

                                  if (!_acceptTerms) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(
                                          0xFF122617,
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                          'Setujui kebijakan dan ketentuan terlebih dahulu.',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final result = await ref
                                      .read(authControllerProvider)
                                      .register(
                                        nama: _namaController.text,
                                        nomorHp: _nomorHpController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );

                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF122617),
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        result.message,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );

                                  if (result.success) {
                                    context.go('/home');
                                  }
                                },
                              ),
                              const SizedBox(height: 22),
                              _AuthSwitchText(
                                normalText: 'Sudah punya akun?',
                                actionText: 'Masuk',
                                onTap: () => context.go('/login'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 0.86,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF41EA67),
            checkColor: const Color(0xFF06160B),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.34),
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 12.8,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.62),
              ),
              children: [
                const TextSpan(text: 'Saya menyetujui '),
                TextSpan(
                  text: 'kebijakan',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.88),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' dan '),
                TextSpan(
                  text: 'ketentuan',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.88),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthSwitchText extends StatelessWidget {
  const _AuthSwitchText({
    required this.normalText,
    required this.actionText,
    required this.onTap,
  });

  final String normalText;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.64),
          ),
          children: [
            TextSpan(text: '$normalText '),
            TextSpan(
              text: actionText,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF41EA67),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
