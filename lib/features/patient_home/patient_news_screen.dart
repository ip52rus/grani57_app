import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../patient_booking/patient_booking_screens.dart';

/// The two temporary, Figma-backed news articles shown from the home carousel.
///
/// Later these values will be supplied by the admin API; keeping the screen
/// data-driven now avoids coupling navigation to a particular card layout.
enum PatientNewsArticle { introduction, newBranch }

class PatientNewsScreen extends StatelessWidget {
  const PatientNewsScreen({
    required this.article,
    this.patientId,
    this.patientName = 'Мария Петрова',
    this.onBookAppointment,
    super.key,
  });

  final PatientNewsArticle article;
  final String? patientId;
  final String patientName;
  final VoidCallback? onBookAppointment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.radius28,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Column(
            children: [
              const SizedBox(height: 44),
              const _NewsHeader(),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 112),
                        child: switch (article) {
                          PatientNewsArticle.introduction =>
                            const _IntroductionArticle(),
                          PatientNewsArticle.newBranch =>
                            const _NewBranchArticle(),
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _NewsBookingAction(
                        onPressed:
                            onBookAppointment ??
                            () => Navigator.of(context).push(
                              patientBookingRoute(
                                context,
                                patientId: patientId,
                                patientName: patientName,
                              ),
                            ),
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

class _NewsHeader extends StatelessWidget {
  const _NewsHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Назад',
              child: InkResponse(
                onTap: () => Navigator.maybePop(context),
                radius: 28,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _BackIcon(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Новости и акции',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackIcon extends StatelessWidget {
  const _BackIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/actions/news_back.svg',
      width: 24,
      height: 24,
    );
  }
}

class _IntroductionArticle extends StatelessWidget {
  const _IntroductionArticle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IntroductionPromo(),
        SizedBox(height: 20),
        _IntroductionTitle(),
        SizedBox(height: 20),
        Text(
          'На первой консультации врач ответит на Ваши вопросы, проведёт осмотр и обсудит дальнейшие шаги.',
          style: AppTypography.body,
        ),
        SizedBox(height: 20),
        _IntroductionDetailsCard(),
      ],
    );
  }
}

class _IntroductionPromo extends StatelessWidget {
  const _IntroductionPromo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 345,
      height: 220,
      child: ClipRRect(
        borderRadius: AppRadii.radius20,
        child: Stack(
          children: [
            const Positioned.fill(child: _PromotionBackground()),
            const _SpectralStreak(left: 155, top: -24, width: 38, height: 288),
            const _SpectralStreak(
              left: 229.07,
              top: 14,
              width: 22,
              height: 236,
            ),
            const Positioned(
              left: 20,
              top: 20,
              width: 167,
              child: _IntroductionPromoCopy(),
            ),
            Positioned(
              left: 191,
              top: 16,
              width: 163,
              height: 200,
              child: Image.asset(
                'assets/images/publications/news_glass_graphic.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpectralStreak extends StatelessWidget {
  const _SpectralStreak({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: 18 * math.pi / 180,
        child: Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x004AAAFF),
                Color(0x1F4AAAFF),
                Color(0x2EB39AEA),
                Color(0xF2FFFFFF),
                Color(0x1AFF4A4D),
                Color(0x4DFFFFFF),
                Color(0x00FFFFFF),
              ],
              stops: [0, .24, .42, .5, .6, .78, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroductionPromoCopy extends StatelessWidget {
  const _IntroductionPromoCopy();

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
        const _GradientText(
          text: 'Сияйте\nизнутри',
          style: AppTypography.display,
          width: 167,
          gradient: _NewsGradients.promo,
        ),
        const SizedBox(height: 8),
        Text(
          'Знакомство с клиникой',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    );
  }
}

class _IntroductionTitle extends StatelessWidget {
  const _IntroductionTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Забота начинается',
          style: AppTypography.heading.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 0),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const _GradientText(
              text: 'со ',
              style: AppTypography.heading,
              width: 30,
              gradient: _NewsGradients.introductionSecondLine,
            ),
            Text(
              'знакомства',
              style: AppTypography.heading.copyWith(color: AppColors.brand),
            ),
          ],
        ),
      ],
    );
  }
}

class _IntroductionDetailsCard extends StatelessWidget {
  const _IntroductionDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.radius20,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailBlock(title: 'Где', text: 'Клиника на Просвещения, 15'),
          SizedBox(height: 12),
          _DetailBlock(
            title: 'Как записаться',
            text: 'Выберите удобное время в приложении.',
          ),
          SizedBox(height: 12),
          Text(
            'Стоимость выбранной услуги будет указана перед подтверждением записи.',
            style: AppTypography.small,
          ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 4),
        Text(text, style: AppTypography.body),
      ],
    );
  }
}

class _NewBranchArticle extends StatelessWidget {
  const _NewBranchArticle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NewBranchPromo(),
        SizedBox(height: 20),
        _NewBranchTitle(),
        SizedBox(height: 20),
        Text(
          'Готовимся встречать пациентов по адресу Большеохтинский проспект, 12. О начале записи сообщим в приложении.',
          style: AppTypography.body,
        ),
        SizedBox(height: 20),
        _AddressCard(),
      ],
    );
  }
}

class _NewBranchPromo extends StatelessWidget {
  const _NewBranchPromo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345,
      height: 288,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.brand,
        borderRadius: AppRadii.radius20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.radiusFull,
            ),
            child: Text(
              'Скоро открытие',
              style: AppTypography.caption.copyWith(color: AppColors.brand),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ещё ближе\nк Вашей улыбке',
            style: AppTypography.title.copyWith(color: AppColors.onBrand),
          ),
          const SizedBox(height: 12),
          Text(
            '57 граней на Охте',
            style: AppTypography.body.copyWith(color: AppColors.onBrand),
          ),
          const Spacer(),
          SvgPicture.asset(
            'assets/icons/actions/pin_48.svg',
            width: 48,
            height: 48,
          ),
        ],
      ),
    );
  }
}

class _NewBranchTitle extends StatelessWidget {
  const _NewBranchTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientText(
          text: 'Новый филиал',
          style: AppTypography.title,
          width: 345,
          gradient: _NewsGradients.newBranchFirstLine,
        ),
        _GradientText(
          text: 'на Большеохтинском',
          style: AppTypography.title,
          width: 345,
          gradient: _NewsGradients.newBranchSecondLine,
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Посмотреть адрес',
      child: Container(
        width: 345,
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.radius20,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/actions/pin_24.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Посмотреть адрес', style: AppTypography.label),
                const SizedBox(height: 4),
                Text(
                  'Большеохтинский пр., 12',
                  style: AppTypography.small.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsBookingAction extends StatelessWidget {
  const _NewsBookingAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      color: AppColors.surface,
      child: SizedBox(
        height: 52,
        child: TextButton(
          onPressed: onPressed,
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(AppColors.accent),
            foregroundColor: WidgetStatePropertyAll(AppColors.onBrand),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: AppRadii.radius12),
            ),
          ),
          child: const Text('Записаться на приём', style: AppTypography.label),
        ),
      ),
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
          stops: [0, .37143, .71429],
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText({
    required this.text,
    required this.style,
    required this.width,
    required this.gradient,
  });

  final String text;
  final TextStyle style;
  final double width;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          gradient.createShader(Rect.fromLTWH(0, 0, width, bounds.height)),
      child: Text(text, style: style.copyWith(color: AppColors.brand)),
    );
  }
}

abstract final class _NewsGradients {
  static const promo = LinearGradient(
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
    stops: [0, .24, .38, .48, .58, .66, .84, 1],
  );

  static const introductionSecondLine = LinearGradient(
    colors: [
      AppColors.brand,
      AppColors.brand,
      AppColors.sky,
      Color(0xFFA46BD5),
      AppColors.coral,
      AppColors.accent,
      AppColors.brand,
    ],
    stops: [0, .099478, .15751, .19896, .24041, .27357, .34817],
  );

  static const newBranchFirstLine = LinearGradient(
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
    stops: [0, .15513, .24562, .31026, .3749, .42661, .54296, .64638],
  );

  static const newBranchSecondLine = LinearGradient(
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
    stops: [0, .22817, .36128, .45635, .55142, .62748, .79861, .95072],
  );
}
