import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.width < 380 ? 96.0 : 104.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8EDB52),
              Color(0xFF6BBF3A),
              Color(0xFF4E9A1F),
              Color(0xFF2E7D32),
              Color(0xFF0F3D00),
            ],
            stops: [0.0, 0.18, 0.42, 0.72, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 92,
              right: -92,
              child: _GlowCircle(size: 230, opacity: 0.12),
            ),
            const Positioned(
              left: -120,
              bottom: 150,
              child: _GlowCircle(size: 300, opacity: 0.10),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _BrandMark(logoSize: logoSize),
                    const SizedBox(height: 28),
                    const Text(
                      'REWORTH',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Helvetica Neue LT Pro',
                        fontFamilyFallback: ['Helvetica Neue', 'Arial'],
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ubah sampah jadi langkah baik',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.instrumentSerif(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Laporkan, kumpulkan poin, dan dukung produk daur ulang dalam satu ekosistem hijau.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.instrumentSerif(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        height: 1.36,
                      ),
                    ),
                    const Spacer(flex: 3),
                    _WelcomeActions(
                      onLogin: () => context.go('/login'),
                      onRegister: () => context.go('/register'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.logoSize});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123F07).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: logoSize * 0.74,
          height: logoSize * 0.74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.96),
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Image.asset(
              'assets/images/logo_reworth.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF0E4F00), Color(0xFF176B09)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onLogin,
                borderRadius: BorderRadius.circular(20),
                child: const Center(
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum punya akun?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onRegister,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('Daftar'),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryLight.withValues(alpha: opacity),
            AppColors.secondary.withValues(alpha: opacity * 0.34),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
