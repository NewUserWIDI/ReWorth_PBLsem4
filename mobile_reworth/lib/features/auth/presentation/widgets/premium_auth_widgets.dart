import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumAuthBackground extends StatelessWidget {
  const PremiumAuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _AuthBackgroundPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  const _AuthBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF08150E), Color(0xFF041009), Color(0xFF020705)],
        stops: [0.0, 0.48, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, basePaint);

    final beamPath = Path()
      ..moveTo(w * 1.10, h * -0.04)
      ..cubicTo(w * 0.96, h * 0.12, w * 0.80, h * 0.34, w * 0.64, h * 0.56)
      ..cubicTo(w * 0.50, h * 0.76, w * 0.35, h * 0.96, w * -0.10, h * 1.10);

    final auraPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.20
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFF41EA67).withValues(alpha: 0.06),
          const Color(0xFF41EA67).withValues(alpha: 0.16),
          const Color(0xFF41EA67).withValues(alpha: 0.18),
          const Color(0xFF2BCB75).withValues(alpha: 0.12),
          const Color(0xFF2BCB75).withValues(alpha: 0.04),
        ],
        stops: const [0.0, 0.22, 0.48, 0.74, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34)
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beamPath, auraPaint);

    final bodyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.060
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFB9FFC8).withValues(alpha: 0.08),
          const Color(0xFF5AF67E).withValues(alpha: 0.24),
          const Color(0xFF41EA67).withValues(alpha: 0.42),
          const Color(0xFF2EDC6C).withValues(alpha: 0.26),
          const Color(0xFF41EA67).withValues(alpha: 0.08),
        ],
        stops: const [0.0, 0.20, 0.48, 0.74, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11)
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beamPath, bodyPaint);

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.012
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFD9FFC3).withValues(alpha: 0.10),
          const Color(0xFFB9FFC8).withValues(alpha: 0.24),
          const Color(0xFF8AFF9E).withValues(alpha: 0.56),
          const Color(0xFF5AF67E).withValues(alpha: 0.38),
          const Color(0xFF41EA67).withValues(alpha: 0.10),
        ],
        stops: const [0.0, 0.18, 0.48, 0.76, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..blendMode = BlendMode.screen;

    canvas.drawPath(beamPath, corePaint);

    canvas.drawRect(
      rect,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    final leftVignettePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withValues(alpha: 0.48),
          Colors.black.withValues(alpha: 0.18),
          Colors.black.withValues(alpha: 0.00),
        ],
        stops: const [0.0, 0.54, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, leftVignettePaint);

    final bottomVignettePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.00),
          Colors.black.withValues(alpha: 0.34),
        ],
        stops: const [0.46, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bottomVignettePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlassAuthCard extends StatelessWidget {
  const GlassAuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.105),
                const Color(0xFF0A1B11).withValues(alpha: 0.66),
                const Color(0xFF020705).withValues(alpha: 0.62),
              ],
              stops: const [0.0, 0.46, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.40),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: const Color(0xFF41EA67).withValues(alpha: 0.08),
                blurRadius: 34,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassTextField extends StatefulWidget {
  const GlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _focused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused
        ? const Color(0xFF41EA67).withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.14);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: Colors.white.withValues(alpha: 0.075),
        border: Border.all(color: borderColor, width: _focused ? 1.35 : 1.05),
        boxShadow: [
          if (_focused)
            BoxShadow(
              color: const Color(0xFF41EA67).withValues(alpha: 0.20),
              blurRadius: 18,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        cursorColor: const Color(0xFF41EA67),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          border: InputBorder.none,
          errorMaxLines: 2,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: const Color(0xFFA8F5B8),
            size: 22,
          ),
          suffixIcon: widget.suffixIcon,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.52),
          ),
          errorStyle: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFFFF8A8A),
          ),
        ),
      ),
    );
  }
}

class PrimaryNeonButton extends StatelessWidget {
  const PrimaryNeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.white.withValues(alpha: 0.10),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: Ink(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF55F57B), Color(0xFF41EA67), Color(0xFF24C957)],
              stops: [0.0, 0.52, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF41EA67).withValues(alpha: 0.34),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF55F57B).withValues(alpha: 0.18),
                blurRadius: 34,
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF06160B),
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF06160B),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
