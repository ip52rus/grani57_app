import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../typography/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.semanticLabel,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final String? semanticLabel;
  final bool fullWidth;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = _ButtonContent(
      label: label,
      isLoading: isLoading,
      textColor: _foregroundColor,
      progressColor: _foregroundColor,
    );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: 52,
        child: TextButton(
          onPressed: _isEnabled ? onPressed : null,
          style: _style,
          child: child,
        ),
      ),
    );
  }

  ButtonStyle get _style {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadii.radius12),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.soft;
        }

        return switch (variant) {
          AppButtonVariant.primary => AppColors.brand,
          AppButtonVariant.secondary => AppColors.soft,
          AppButtonVariant.ghost => Colors.transparent,
          AppButtonVariant.danger => AppColors.error,
        };
      }),
      foregroundColor: WidgetStatePropertyAll(_foregroundColor),
      overlayColor: WidgetStatePropertyAll(
        _foregroundColor.withValues(alpha: 0.08),
      ),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const BorderSide(color: AppColors.border);
        }

        return switch (variant) {
          AppButtonVariant.primary => BorderSide.none,
          AppButtonVariant.secondary => const BorderSide(color: AppColors.soft),
          AppButtonVariant.ghost => const BorderSide(color: AppColors.border),
          AppButtonVariant.danger => BorderSide.none,
        };
      }),
      textStyle: const WidgetStatePropertyAll(AppTypography.label),
    );
  }

  Color get _foregroundColor {
    if (!_isEnabled) {
      return AppColors.secondary;
    }

    return switch (variant) {
      AppButtonVariant.primary => AppColors.onBrand,
      AppButtonVariant.secondary => AppColors.brand,
      AppButtonVariant.ghost => AppColors.brand,
      AppButtonVariant.danger => AppColors.onBrand,
    };
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.textColor,
    required this.progressColor,
  });

  final String label;
  final bool isLoading;
  final Color textColor;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      );
    }

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.label.copyWith(color: textColor),
    );
  }
}
