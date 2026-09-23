import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../../core/navigation/app_page_route.dart';
import '../patient_auth/patient_phone_login_screen.dart';
import '../patient_home/patient_home_screen.dart';
import '../patient_notifications/patient_notification_screens.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({
    this.patientId,
    this.patientName = 'Мария Петрова',
    required this.phone,
    required this.sessionStore,
    this.onNavigationSelected,
    super.key,
  });

  final String phone;
  final String? patientId;
  final String patientName;
  final DemoSessionStore sessionStore;
  final ValueChanged<int>? onNavigationSelected;

  Future<void> _signOut(BuildContext context) async {
    await sessionStore.clearSession();
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      appPageRoute<void>(
        context,
        builder: (_) => PatientPhoneLoginScreen(sessionStore: sessionStore),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: _ProfileFigma.background,
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Column(
            children: [
              const SizedBox(height: 44),
              const _ProfileHeader(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 152,
                      child: _ProfileContent(
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 100,
                      height: 52,
                      child: _SignOutButton(onPressed: () => _signOut(context)),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 80,
                      child: PatientBottomNavigation(
                        selectedIndex: 4,
                        onSelected: onNavigationSelected,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _ProfileHeaderLabel(),
      ),
    ),
  );
}

class _ProfileHeaderLabel extends StatelessWidget {
  const _ProfileHeaderLabel();

  @override
  Widget build(BuildContext context) => Text(
    'Профиль',
    style: AppTypography.label.copyWith(color: AppColors.brand),
  );
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.patientId, required this.patientName});

  final String? patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    final profile = context
        .findAncestorWidgetOfExactType<PatientProfileScreen>()!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _ProfileSummaryCard(name: profile.patientName, phone: profile.phone),
        const SizedBox(height: 20),
        _ProfileActionCard(
          iconAsset: 'assets/icons/actions/notifications_clean.svg',
          title: 'Уведомления',
          subtitle: 'Напоминания и новости',
          onTap: () => Navigator.of(context).push(
            appPageRoute<void>(
              context,
              builder: (_) => PatientNotificationSettingsScreen(
                patientId: patientId ?? 'demo_patient',
                patientName: patientName,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _ProfileActionCard(
          iconAsset: 'assets/icons/actions/phone_clean.svg',
          title: 'Связаться с клиникой',
          subtitle: 'Телефоны, адреса и почта',
        ),
        const SizedBox(height: 20),
        const _ProfileActionCard(
          iconAsset: 'assets/icons/actions/lock_clean.svg',
          title: 'Личные данные',
          subtitle: 'Редактирование через клинику',
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.name, required this.phone});

  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) => Container(
    height: 164,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/icons/profile/profile_avatar_clean.svg',
          width: 40,
          height: 40,
        ),
        const SizedBox(height: 12),
        Text(name, style: AppTypography.title.copyWith(color: AppColors.brand)),
        const SizedBox(height: 12),
        Text(
          phone,
          style: AppTypography.body.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadii.radius20,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.radius20,
        ),
        child: Row(
          children: [
            SvgPicture.asset(iconAsset, width: 24, height: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: AppTypography.label),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.small.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: AppRadii.radius12,
    child: InkWell(
      onTap: onPressed,
      borderRadius: AppRadii.radius12,
      child: Center(
        child: Text(
          'Выйти из аккаунта',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
      ),
    ),
  );
}

abstract final class _ProfileFigma {
  static const background = Color(0xFFF5F8FC);
}
