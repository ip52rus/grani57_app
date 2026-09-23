import 'package:flutter/material.dart';

import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_spacing.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../admin/admin_shell_screen.dart';
import '../doctor_schedule/doctor_schedule_screen.dart';
import '../patient_auth/patient_phone_login_screen.dart';

class PatientAuthPlaceholder extends StatelessWidget {
  const PatientAuthPlaceholder({super.key, this.sessionStore});

  final DemoSessionStore? sessionStore;

  @override
  Widget build(BuildContext context) {
    return PatientPhoneLoginScreen(sessionStore: sessionStore);
  }
}

class DoctorShellPlaceholder extends StatelessWidget {
  const DoctorShellPlaceholder({
    super.key,
    this.sessionStore,
    this.doctorId,
    this.doctorName,
  });

  final DemoSessionStore? sessionStore;
  final String? doctorId;
  final String? doctorName;

  @override
  Widget build(BuildContext context) => DoctorScheduleScreen(
    sessionStore: sessionStore,
    doctorId: doctorId,
    doctorName: doctorName,
  );
}

class AdminShellPlaceholder extends StatelessWidget {
  const AdminShellPlaceholder({super.key, this.sessionStore});

  final DemoSessionStore? sessionStore;

  @override
  Widget build(BuildContext context) =>
      AdminShellScreen(sessionStore: sessionStore);
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
