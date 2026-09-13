import 'package:flutter/material.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_spacing.dart';
import '../../core/design_system/typography/app_typography.dart';

class EmployeeAuthPlaceholder extends StatelessWidget {
  const EmployeeAuthPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Employee authentication',
                  textAlign: TextAlign.center,
                  style: AppTypography.heading.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: AppSpacing.x8),
                Text(
                  'Development placeholder',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.x24),
                AppButton(
                  label: 'Назад',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
