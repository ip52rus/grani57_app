import 'package:flutter/material.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_spacing.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../patient_auth/patient_phone_login_screen.dart';

class PatientShellPlaceholder extends StatelessWidget {
  const PatientShellPlaceholder({super.key, this.sessionStore});

  final DemoSessionStore? sessionStore;

  Future<void> _clearDemoSession(BuildContext context) async {
    await (sessionStore ?? DemoSessionStore()).clearSession();
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => PatientPhoneLoginScreen(sessionStore: sessionStore),
      ),
      (_) => false,
    );
  }

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
                  'Patient shell',
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
                  label: 'Clear demo session',
                  variant: AppButtonVariant.ghost,
                  semanticLabel: 'Development only clear demo session',
                  onPressed: () => _clearDemoSession(context),
                ),
                const SizedBox(height: AppSpacing.x8),
                Text(
                  'Development only',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
