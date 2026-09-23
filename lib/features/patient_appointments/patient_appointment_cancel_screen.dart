import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_patient_appointments.dart';
import 'patient_appointment_reschedule_screen.dart';

class PatientAppointmentCancelScreen extends StatelessWidget {
  const PatientAppointmentCancelScreen({
    required this.appointment,
    this.onChooseAnotherTime,
    this.onAppointmentChanged,
    super.key,
  });

  final DemoPatientAppointment appointment;
  final VoidCallback? onChooseAnotherTime;
  final ValueChanged<DemoPatientAppointment>? onAppointmentChanged;

  Future<void> _chooseAnotherTime(BuildContext context) async {
    if (onChooseAnotherTime case final callback?) {
      callback();
      return;
    }

    await Navigator.of(context).push<void>(
      appPageRoute<void>(
        context,
        builder: (_) => PatientAppointmentRescheduleScreen(
          appointment: appointment,
          onConfirmed: onAppointmentChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.radius28,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Column(
          children: [
            const SizedBox(height: 44),
            const _CancelHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const SizedBox(height: 20),
                    const _CancelTitle(),
                    const SizedBox(height: 20),
                    Text(
                      '${_formatAppointmentDate(appointment.startsAt)}\n'
                      '${appointment.service.replaceFirst(' стоматолога', '')} '
                      '· ${appointment.doctor}',
                      style: AppTypography.small.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _CancellationInfoCard(),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Сохранить запись',
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Выбрать другое время',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _chooseAnotherTime(context),
                    ),
                    const SizedBox(height: 20),
                    _WhiteDangerButton(
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CancelHeader extends StatelessWidget {
  const _CancelHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Назад к деталям приёма',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.maybePop(context),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    'assets/icons/actions/news_back.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Отмена записи',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CancelTitle extends StatelessWidget {
  const _CancelTitle();

  static const _gradient = LinearGradient(
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
    stops: [0, 0.19061, 0.3018, 0.38122, 0.46064, 0.52417, 0.66713, 0.7942],
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (_) =>
          _gradient.createShader(const Rect.fromLTWH(0, 0, 345, 36)),
      child: const Text('Отменить приём?', style: AppTypography.title),
    ),
  );
}

class _CancellationInfoCard extends StatelessWidget {
  const _CancellationInfoCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Это время станет доступно\nдругим пациентам.',
          style: AppTypography.body,
        ),
        const SizedBox(height: 12),
        Text(
          'Если вам неудобна дата, можно перенести запись.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _WhiteDangerButton extends StatelessWidget {
  const _WhiteDangerButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Да, отменить приём',
    child: SizedBox(
      height: 52,
      child: TextButton(
        onPressed: onPressed,
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(12)),
          backgroundColor: WidgetStatePropertyAll(AppColors.surface),
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.radius12),
          ),
        ),
        child: Text(
          'Да, отменить приём',
          style: AppTypography.label.copyWith(color: AppColors.error),
        ),
      ),
    ),
  );
}

String _formatAppointmentDate(DateTime date) =>
    '${date.day} ${_monthNameGenitive(date.month)} · ${_formatTime(date)}';

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

String _monthNameGenitive(int month) => const [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
][month - 1];
