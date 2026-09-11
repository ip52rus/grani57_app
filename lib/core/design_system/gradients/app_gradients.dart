import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

abstract final class AppGradients {
  static const brandHeader = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.brand,
      AppColors.brand,
      AppColors.sky,
      Color(0xFFA46BD5),
      AppColors.coral,
      AppColors.accent,
      AppColors.brand,
      AppColors.brand,
    ],
    stops: [0, 0.24, 0.38, 0.48, 0.58, 0.66, 0.84, 1],
  );
}
