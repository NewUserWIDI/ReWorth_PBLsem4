import 'package:flutter/material.dart';
import '../../core/constants/app_typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: AppTypography.body,
        textAlign: TextAlign.center,
      ),
    );
  }
}
