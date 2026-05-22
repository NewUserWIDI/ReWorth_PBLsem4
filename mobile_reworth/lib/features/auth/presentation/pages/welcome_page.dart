import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final horizontalPadding =
        (size.width * 0.09).clamp(28.0, 44.0).toDouble();

    final titleSize =
        (size.width * 0.115).clamp(46.0, 64.0).toDouble();

    final taglineSize =
        (size.width * 0.066).clamp(21.0, 32.0).toDouble();

    final bodySize =
        (size.width * 0.040).clamp(15.0, 18.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFF020705),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _WelcomeBackground(),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;

                final textTop = (h * 0.22).clamp(88.0, 180.0).toDouble();
                final bottomPadding = h < 700 ? 22.0 : 30.0;

                return Stack(
                  children: [
                    Positioned(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: textTop,
                      child: _WelcomeTextBlock(
                        titleSize: titleSize,
                        taglineSize: taglineSize,
                        bodySize: bodySize,
                      ),
                    ),

                    Positioned(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: bottomPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _GetStartedPill(
                            onTap: () => context.go('/login'),
                          ),
                          const SizedBox(height: 20),
                          _RegisterLink(
                            onTap: () => context.go('/register'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _WelcomeBackgroundPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _WelcomeBackgroundPainter extends CustomPainter {
  const _WelcomeBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF08150E),
          Color(0xFF041009),
          Color(0xFF020705),
        ],
        stops: [0.0, 0.48, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, basePaint);

    // Ambient kanan tipis, jangan terlalu dominan.
    final rightGlowRect = Rect.fromCenter(
      center: Offset(w * 1.10, h * 0.34),
      width: w * 0.88,
      height: h * 0.82,
    );

    final rightGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF35E06C).withOpacity(0.14),
          const Color(0xFF1FA55A).withOpacity(0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(rightGlowRect);

    canvas.drawOval(rightGlowRect, rightGlowPaint);

    // J-SHAPE BEAM:
    // Start dari kanan atas, turun miring, lalu melengkung ke kiri bawah.
    final beamPath = Path()
      ..moveTo(w * 1.10, h * -0.04)
      ..cubicTo(
        w * 0.96,
        h * 0.12,
        w * 0.80,
        h * 0.34,
        w * 0.64,
        h * 0.56,
      )
      ..cubicTo(
        w * 0.50,
        h * 0.76,
        w * 0.35,
        h * 0.96,
        w * -0.10,
        h * 1.10,
      );

    // Layer 1: aura besar tapi ramping.
    final auraPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.22
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFF41EA67).withOpacity(0.08),
          const Color(0xFF41EA67).withOpacity(0.20),
          const Color(0xFF41EA67).withOpacity(0.22),
          const Color(0xFF2BCB75).withOpacity(0.16),
          const Color(0xFF2BCB75).withOpacity(0.08),
        ],
        stops: const [0.0, 0.22, 0.48, 0.74, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        34,
      )
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beamPath, auraPaint);

    // Layer 2: outer glow yang lebih terlihat.
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.125
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFF55F57B).withOpacity(0.08),
          const Color(0xFF41EA67).withOpacity(0.30),
          const Color(0xFF41EA67).withOpacity(0.46),
          const Color(0xFF2EDC6C).withOpacity(0.30),
          const Color(0xFF1F8A50).withOpacity(0.08),
        ],
        stops: const [0.0, 0.18, 0.46, 0.74, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        20,
      )
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beamPath, outerPaint);

    // Layer 3: body beam, supaya garis konsisten dari atas sampai bawah.
    final bodyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.060
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFB9FFC8).withOpacity(0.10),
          const Color(0xFF5AF67E).withOpacity(0.30),
          const Color(0xFF41EA67).withOpacity(0.54),
          const Color(0xFF2EDC6C).withOpacity(0.34),
          const Color(0xFF41EA67).withOpacity(0.12),
        ],
        stops: const [0.0, 0.20, 0.48, 0.74, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        10,
      )
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beamPath, bodyPaint);

    // Layer 4: core line paling penting.
    // Ini yang bikin beam terlihat "bersinar", bukan cuma blur.
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.016
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFD9FFC3).withOpacity(0.12),
          const Color(0xFFB9FFC8).withOpacity(0.34),
          const Color(0xFF8AFF9E).withOpacity(0.72),
          const Color(0xFF5AF67E).withOpacity(0.54),
          const Color(0xFF41EA67).withOpacity(0.16),
        ],
        stops: const [0.0, 0.18, 0.48, 0.76, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        3.2,
      )
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beamPath, corePaint);

    // Highlight tipis tanpa blur besar.
    final sharpCorePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.006
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFFFFFFF).withOpacity(0.00),
          const Color(0xFFCFFFCB).withOpacity(0.22),
          const Color(0xFFA6F08C).withOpacity(0.42),
          const Color(0xFF55F57B).withOpacity(0.22),
          const Color(0xFFFFFFFF).withOpacity(0.00),
        ],
        stops: const [0.0, 0.20, 0.48, 0.78, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beamPath, sharpCorePaint);

    // Area kiri harus tetap gelap untuk text.
    final leftVignettePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withOpacity(0.48),
          Colors.black.withOpacity(0.22),
          Colors.black.withOpacity(0.00),
        ],
        stops: const [0.0, 0.54, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, leftVignettePaint);

    final topVignettePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(0.20),
          Colors.black.withOpacity(0.00),
        ],
        stops: const [0.0, 0.30],
      ).createShader(rect);

    canvas.drawRect(rect, topVignettePaint);

    final bottomVignettePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(0.00),
          Colors.black.withOpacity(0.34),
        ],
        stops: const [0.46, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bottomVignettePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WelcomeTextBlock extends StatelessWidget {
  const _WelcomeTextBlock({
    required this.titleSize,
    required this.taglineSize,
    required this.bodySize,
  });

  final double titleSize;
  final double taglineSize;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REWORTH',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: titleSize,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.35,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Ubah sampah jadi\nlangkah baik',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.95),
            fontSize: taglineSize,
            height: 1.16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Laporkan, kumpulkan poin, dan\n'
          'dukung produk daur ulang dalam\n'
          'satu ekosistem hijau.',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.76),
            fontSize: bodySize,
            height: 1.58,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.04,
          ),
        ),
      ],
    );
  }
}

class _GetStartedPill extends StatefulWidget {
  const _GetStartedPill({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<_GetStartedPill> createState() => _GetStartedPillState();
}

class _GetStartedPillState extends State<_GetStartedPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        scale: _pressed ? 0.985 : 1,
        child: Container(
          width: double.infinity,
          height: 68,
          padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF0C1E14).withOpacity(0.98),
                const Color(0xFF06110B).withOpacity(0.98),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.36),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: const Color(0xFF41EA67).withOpacity(0.10),
                blurRadius: 26,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF55F57B),
                      Color(0xFF41EA67),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF41EA67).withOpacity(0.34),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF06160B),
                  size: 28,
                ),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ),

              // Jangan pakai text >>> karena bisa jadi ??? di Flutter Web.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.34),
                    size: 22,
                  ),
                  Transform.translate(
                    offset: const Offset(-7, 0),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.40),
                      size: 22,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-14, 0),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.46),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink({
    required this.onTap,
  });

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
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.58),
          ),
          children: [
            const TextSpan(text: 'Belum punya akun?  '),
            TextSpan(
              text: 'Daftar',
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