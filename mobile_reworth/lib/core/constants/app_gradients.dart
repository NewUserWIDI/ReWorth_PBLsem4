import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFB5FF77),
      Color(0xFF6BAD34),
      Color(0xFF5CA61E),
      Color(0xFF3B6D11),
    ],
    stops: [0.0, 0.33, 0.54, 0.90],
  );

  static const disabledSurface = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.disabled, AppColors.disabled],
  );
}
