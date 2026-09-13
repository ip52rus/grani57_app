import 'package:flutter/material.dart';

import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_spacing.dart';
import '../../core/design_system/typography/app_typography.dart';

class PatientAuthPlaceholder extends StatelessWidget {
  const PatientAuthPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StartupPlaceholder(title: 'Patient authentication');
  }
}

class PatientShellPlaceholder extends StatelessWidget {
  const PatientShellPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StartupPlaceholder(title: 'Patient shell');
  }
}

class DoctorShellPlaceholder extends StatelessWidget {
  const DoctorShellPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StartupPlaceholder(title: 'Doctor shell');
  }
}

class AdminShellPlaceholder extends StatelessWidget {
  const AdminShellPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StartupPlaceholder(title: 'Administrator shell');
  }
}

class _StartupPlaceholder extends StatelessWidget {
  const _StartupPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
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
            ],
          ),
        ),
      ),
    );
  }
}
