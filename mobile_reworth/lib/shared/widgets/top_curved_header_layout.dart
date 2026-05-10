import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class TopCurvedHeaderLayout extends StatelessWidget {
  const TopCurvedHeaderLayout({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s16),
  });

  final String title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 164;
    const double overlap = 12;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: headerHeight,
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
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Center(
                  child: Text(
                    title,
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: headerHeight - overlap,
            child: Container(
              width: double.infinity,
              padding: padding,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
