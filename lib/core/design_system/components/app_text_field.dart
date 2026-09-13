import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../typography/app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: AppSpacing.x8),
            TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              autofillHints: autofillHints,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: AppTypography.body.copyWith(color: AppColors.text),
              decoration: InputDecoration(
                hintText: hintText,
                errorText: errorText,
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
