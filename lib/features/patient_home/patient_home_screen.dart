import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../mock_data/demo_patient_appointments.dart';
import '../patient_appointments/patient_appointment_details_screen.dart';
import '../patient_booking/patient_booking_screens.dart';
import '../patient_notifications/patient_notification_screens.dart';
import 'patient_news_screen.dart';

enum PatientHomeState {
  noConnectedData,
  upcomingAppointment,
  completedAppointment,
}

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({
    super.key,
    this.patientId,
    this.patientName = 'Мария',
    this.patientFullName = 'Мария Петрова',
    this.homeState = PatientHomeState.noConnectedData,
    this.bottomNavigation,
  });

  final String? patientId;
  final String patientName;
  final String patientFullName;
  final PatientHomeState homeState;
  final Widget? bottomNavigation;

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final _newsIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _newsIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: _HomeFigma.background,
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Column(
            children: [
              const SizedBox(height: 44),
              _HomeHeader(
                patientId: widget.patientId,
                patientName: widget.patientFullName,
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            child: _HomeContent(
                              patientName: widget.patientName,
                              patientId: widget.patientId,
                              patientFullName: widget.patientFullName,
                              homeState: widget.homeState,
                              newsIndex: _newsIndex,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _NewsCarousel(
                            activeIndex: _newsIndex,
                            patientId: widget.patientId,
                            patientName: widget.patientFullName,
                            useClinicIntroduction:
                                widget.homeState !=
                                PatientHomeState.noConnectedData,
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(24, 20, 24, 104),
                            child: SizedBox(
                              height: 16,
                              child: Text(
                                'Листайте карточки, чтобы узнать больше',
                                style: _HomeFigma.caption,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 80,
                      child:
                          widget.bottomNavigation ??
                          const PatientBottomNavigation(),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.patientId, required this.patientName});

  final String? patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/brand/logo_primary_clean.svg',
              width: 140,
              height: 40.13,
            ),
            const Spacer(),
            Semantics(
              button: true,
              label: 'Открыть уведомления',
              child: InkWell(
                customBorder: const CircleBorder(),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                onTap: () => Navigator.of(context).push(
                  appPageRoute<void>(
                    context,
                    builder: (_) => PatientNotificationsScreen(
                      patientId: patientId,
                      patientName: patientName,
                    ),
                  ),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/actions/notifications.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.patientName,
    required this.patientId,
    required this.patientFullName,
    required this.homeState,
    required this.newsIndex,
  });

  final String patientName;
  final String? patientId;
  final String patientFullName;
  final PatientHomeState homeState;
  final ValueNotifier<int> newsIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Здравствуйте, $patientName',
          maxLines: 2,
          style: AppTypography.title.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 20),
        const SizedBox(
          height: 20,
          child: Text('Забота о Вашей улыбке — рядом', style: _HomeFigma.small),
        ),
        const SizedBox(height: 20),
        _PatientRecordCard(state: homeState, patientId: patientId),
        const SizedBox(height: 20),
        _HomePrimaryButton(patientId: patientId, patientName: patientFullName),
        const SizedBox(height: 20),
        _NewsHeader(activeIndex: newsIndex),
      ],
    );
  }
}

class _PatientRecordCard extends StatelessWidget {
  const _PatientRecordCard({required this.state, required this.patientId});

  final PatientHomeState state;
  final String? patientId;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PatientHomeState.noConnectedData => const _NoConnectedDataCard(),
      PatientHomeState.upcomingAppointment => _UpcomingAppointmentCard(
        appointment: DemoPatientAppointments.upcomingFor(patientId).firstOrNull,
      ),
      PatientHomeState.completedAppointment =>
        const _CompletedAppointmentCard(),
    };
  }
}

class _NoConnectedDataCard extends StatelessWidget {
  const _NoConnectedDataCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.soft,
        borderRadius: AppRadii.radius20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
            child: Text(
              'Добро пожаловать в 57 ГРАНЕЙ',
              style: _HomeFigma.caption,
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 28, child: _GradientCardTitle()),
          const SizedBox(height: 12),
          const SizedBox(
            height: 60,
            child: Text(
              'Уже лечились у нас? Обратитесь к\nадминистратору клиники, чтобы видеть свою\nисторию лечения и документы в приложении.',
              style: _HomeFigma.cardBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingAppointmentCard extends StatelessWidget {
  const _UpcomingAppointmentCard({required this.appointment});

  final DemoPatientAppointment? appointment;

  void _openDetails(BuildContext context) {
    final selectedAppointment = appointment;
    if (selectedAppointment == null) return;

    Navigator.of(context).push(
      appPageRoute<void>(
        context,
        builder: (_) =>
            PatientAppointmentDetailsScreen(appointment: selectedAppointment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 208,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.brand,
        borderRadius: AppRadii.radius20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VisitLabel(
            text: 'БЛИЖАЙШИЙ ПРИЁМ',
            backgroundColor: AppColors.surface,
            textColor: AppColors.brand,
          ),
          const SizedBox(height: 12),
          Text(
            '14 сентября · 10:30',
            maxLines: 1,
            style: AppTypography.heading.copyWith(color: AppColors.onBrand),
          ),
          const SizedBox(height: 12),
          Text(
            'Консультация стоматолога',
            maxLines: 1,
            style: AppTypography.body.copyWith(color: AppColors.onBrand),
          ),
          const SizedBox(height: 12),
          Text(
            'Анна Смирнова · Просвещения, 15',
            maxLines: 1,
            style: _HomeFigma.small.copyWith(color: AppColors.onBrand),
          ),
          const SizedBox(height: 12),
          _AppointmentDetailsAction(
            onTap: appointment == null ? null : () => _openDetails(context),
          ),
        ],
      ),
    );
  }
}

class _CompletedAppointmentCard extends StatelessWidget {
  const _CompletedAppointmentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 236,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.radius20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VisitLabel(
            text: 'Приём завершён',
            backgroundColor: AppColors.successBg,
            textColor: AppColors.success,
          ),
          const SizedBox(height: 12),
          Text(
            '22 августа · 12:00',
            style: AppTypography.heading.copyWith(color: AppColors.brand),
          ),
          const SizedBox(height: 12),
          Text(
            'Профессиональная гигиена',
            style: AppTypography.body.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 12),
          const Text(
            'Анна Смирнова · Просвещения, 15',
            style: _HomeFigma.small,
          ),
          const SizedBox(height: 12),
          Container(
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.soft,
              borderRadius: AppRadii.radius12,
            ),
            child: Text(
              'Заключение врача',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitLabel extends StatelessWidget {
  const _VisitLabel({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.radiusFull,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(color: textColor),
      ),
    );
  }
}

class _AppointmentDetailsAction extends StatelessWidget {
  const _AppointmentDetailsAction({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Посмотреть запись',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 24,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Посмотреть запись',
                  style: AppTypography.label.copyWith(color: AppColors.onBrand),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/actions/arrow_forward_clean.svg',
                width: 24,
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientCardTitle extends StatelessWidget {
  const _GradientCardTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => _HomeFigma.cardGradient.createShader(
        Rect.fromLTWH(0, 0, 305, bounds.height),
      ),
      child: Text(
        'Начните с записи на приём',
        style: AppTypography.heading.copyWith(color: AppColors.brand),
      ),
    );
  }
}

class _HomePrimaryButton extends StatelessWidget {
  const _HomePrimaryButton({
    required this.patientId,
    required this.patientName,
  });

  final String? patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: AppRadii.radius12,
      child: InkWell(
        borderRadius: AppRadii.radius12,
        onTap: () => Navigator.of(context).push(
          patientBookingRoute(
            context,
            patientId: patientId,
            patientName: patientName,
          ),
        ),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              'Записаться на приём',
              style: AppTypography.label.copyWith(color: AppColors.onBrand),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsHeader extends StatelessWidget {
  const _NewsHeader({required this.activeIndex});

  final ValueListenable<int> activeIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          const Expanded(child: _GradientNewsTitle()),
          const SizedBox(width: 8),
          ValueListenableBuilder<int>(
            valueListenable: activeIndex,
            builder: (context, index, child) => SizedBox(
              width: 64,
              height: 20,
              child: Text(
                '${(index + 1).toString().padLeft(2, '0')} / 02',
                style: _HomeFigma.small,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientNewsTitle extends StatelessWidget {
  const _GradientNewsTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => _HomeFigma.newsGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        'Новости и акции',
        style: AppTypography.heading.copyWith(color: AppColors.brand),
      ),
    );
  }
}

class _NewsCarousel extends StatefulWidget {
  const _NewsCarousel({
    required this.activeIndex,
    required this.useClinicIntroduction,
    required this.patientId,
    required this.patientName,
  });

  final ValueNotifier<int> activeIndex;
  final bool useClinicIntroduction;
  final String? patientId;
  final String patientName;

  @override
  State<_NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<_NewsCarousel> {
  static const _pageExtent = 333.0;
  static const _viewportWidth = 381.0;
  late final _pageController = PageController(
    viewportFraction: _pageExtent / _viewportWidth,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: _viewportWidth,
        height: 192,
        child: PageView(
          key: const ValueKey('patient.home.news.carousel'),
          controller: _pageController,
          clipBehavior: Clip.none,
          onPageChanged: (index) => widget.activeIndex.value = index,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _NewsArticleLink(
                article: PatientNewsArticle.introduction,
                patientId: widget.patientId,
                patientName: widget.patientName,
                child: widget.useClinicIntroduction
                    ? const _ClinicIntroductionCard()
                    : const _GiftCertificatesCard(),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _NewsArticleLink(
                article: PatientNewsArticle.newBranch,
                patientId: widget.patientId,
                patientName: widget.patientName,
                child: widget.useClinicIntroduction
                    ? const _NewBranchCard()
                    : const _DisconnectedNewBranchCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsArticleLink extends StatelessWidget {
  const _NewsArticleLink({
    required this.article,
    required this.child,
    required this.patientId,
    required this.patientName,
  });

  final PatientNewsArticle article;
  final Widget child;
  final String? patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Открыть новость',
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.radius20,
        child: InkWell(
          borderRadius: AppRadii.radius20,
          onTap: () {
            Navigator.of(context).push(
              appPageRoute<void>(
                context,
                builder: (_) => PatientNewsScreen(
                  article: article,
                  patientId: patientId,
                  patientName: patientName,
                ),
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }
}

class _GiftCertificatesCard extends StatelessWidget {
  const _GiftCertificatesCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius20,
      child: SizedBox(
        width: 321,
        height: 192,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -22.5,
              top: -7,
              width: 366,
              height: 206,
              child: Image.asset(
                'assets/images/publications/gift_certificates.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicIntroductionCard extends StatelessWidget {
  const _ClinicIntroductionCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius20,
      child: SizedBox(
        width: 321,
        height: 192,
        child: Stack(
          children: [
            const Positioned.fill(child: _PromotionBackground()),
            const Positioned(
              left: 20,
              top: 20,
              width: 167,
              child: _ClinicIntroductionCopy(),
            ),
            Positioned(
              left: 157,
              top: 0,
              width: 150,
              height: 187,
              child: Image.asset(
                'assets/images/brand/glass_tooth.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicIntroductionCopy extends StatelessWidget {
  const _ClinicIntroductionCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ЗАБОТА О СЕБЕ',
          style: AppTypography.caption.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => _HomeFigma.cardGradient.createShader(
              Rect.fromLTWH(0, 0, 167, bounds.height),
            ),
            child: Text(
              'Сияйте\nизнутри',
              style: AppTypography.title.copyWith(color: AppColors.brand),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Знакомство с клиникой', style: _HomeFigma.small),
      ],
    );
  }
}

class _NewBranchCard extends StatelessWidget {
  const _NewBranchCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius20,
      child: SizedBox(
        width: 321,
        height: 192,
        child: Stack(
          children: [
            const Positioned.fill(child: _PromotionBackground()),
            const Positioned(
              left: 20,
              top: 20,
              width: 170,
              child: _NewBranchCopy(),
            ),
            Positioned(
              left: 157,
              top: 40,
              width: 180,
              height: 172,
              child: Image.asset(
                'assets/images/brand/glass_smile.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisconnectedNewBranchCard extends StatelessWidget {
  const _DisconnectedNewBranchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 321,
      height: 192,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.brand,
        borderRadius: AppRadii.radius20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'НОВЫЙ ФИЛИАЛ',
            style: AppTypography.caption.copyWith(color: AppColors.onBrand),
          ),
          const SizedBox(height: 8),
          Text(
            'Скоро\nна Охте',
            style: AppTypography.title.copyWith(color: AppColors.onBrand),
          ),
          const Spacer(),
          Text(
            'Большеохтинский, 12',
            style: AppTypography.small.copyWith(color: AppColors.onBrand),
          ),
        ],
      ),
    );
  }
}

class _NewBranchCopy extends StatelessWidget {
  const _NewBranchCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'НОВЫЙ ФИЛИАЛ',
          style: AppTypography.caption.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => _HomeFigma.cardGradient.createShader(
              Rect.fromLTWH(0, 0, 155, bounds.height),
            ),
            child: Text(
              'Скоро\nна Охте',
              style: AppTypography.title.copyWith(color: AppColors.brand),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Большеохтинский, 12', style: _HomeFigma.small),
      ],
    );
  }
}

class _PromotionBackground extends StatelessWidget {
  const _PromotionBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F5FD), AppColors.soft],
          stops: [0, 0.37143, 0.71429],
        ),
      ),
    );
  }
}

class PatientBottomNavigation extends StatelessWidget {
  const PatientBottomNavigation({
    super.key,
    this.selectedIndex = 0,
    this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF).withValues(alpha: 0.14),
            border: const Border(top: BorderSide(color: Color(0x8CFFFFFF))),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1409275A),
                offset: Offset(0, -4),
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
          child: Row(
            children: [
              _NavigationItem(
                label: 'Главная',
                icon: _NavIcon.home,
                active: selectedIndex == 0,
                onTap: () => onSelected?.call(0),
              ),
              _NavigationItem(
                label: 'Приёмы',
                icon: _NavIcon.appointments,
                active: selectedIndex == 1,
                onTap: () => onSelected?.call(1),
              ),
              _NavigationItem(
                label: 'Документы',
                icon: _NavIcon.documents,
                active: selectedIndex == 2,
                onTap: () => onSelected?.call(2),
              ),
              _NavigationItem(
                label: 'Клиники',
                icon: _NavIcon.clinics,
                active: selectedIndex == 3,
                onTap: () => onSelected?.call(3),
              ),
              _NavigationItem(
                label: 'Профиль',
                icon: _NavIcon.profile,
                active: selectedIndex == 4,
                onTap: () => onSelected?.call(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NavIcon { home, appointments, documents, clinics, profile }

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    this.active = false,
    this.onTap,
  });

  final String label;
  final _NavIcon icon;
  final bool active;
  final VoidCallback? onTap;

  String get _asset {
    final state = active ? 'active' : 'inactive';
    return switch (icon) {
      _NavIcon.home => 'assets/icons/navigation/nav_home_${state}_clean.svg',
      _NavIcon.appointments =>
        'assets/icons/navigation/nav_appointments_${state}_clean.svg',
      _NavIcon.documents =>
        'assets/icons/navigation/nav_documents_${state}_clean.svg',
      _NavIcon.clinics =>
        'assets/icons/navigation/nav_clinics_${state}_clean.svg',
      _NavIcon.profile =>
        'assets/icons/navigation/nav_profile_${state}_clean.svg',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.radius12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 30,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: active ? AppColors.soft : Colors.transparent,
                  borderRadius: AppRadii.radiusFull,
                ),
                child: SvgPicture.asset(_asset, width: 22, height: 22),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 16,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: active ? AppColors.brand : AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class _HomeFigma {
  static const background = Color(0xFFF5F8FC);

  static const cardGradient = LinearGradient(
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
    stops: [0, 0.20931, 0.33141, 0.41862, 0.50584, 0.57561, 0.73259, 0.87213],
  );

  static const newsGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.brand,
      AppColors.brand,
      AppColors.sky,
      Color(0xFFA46BD5),
      AppColors.coral,
      AppColors.accent,
    ],
    stops: [0, 0.20614, 0.33929, 0.41630, 0.49651, 0.57030],
  );

  static const small = AppTypography.small;
  static const caption = AppTypography.caption;
  static const cardBody = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    height: 20 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.text,
  );
}
