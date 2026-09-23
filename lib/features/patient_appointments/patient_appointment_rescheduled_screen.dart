import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../mock_data/demo_patient_appointments.dart';

/// Final state shown after an appointment has been successfully rescheduled.
///
/// The route is placed directly above the appointments screen, so both the
/// header back action and the primary button return to the updated list.
class PatientAppointmentRescheduledScreen extends StatelessWidget {
  const PatientAppointmentRescheduledScreen({
    required this.appointment,
    required this.previousStart,
    super.key,
  });

  final DemoPatientAppointment appointment;
  final DateTime previousStart;

  void _returnToAppointments(BuildContext context) =>
      Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.radius28,
    child: Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Column(
          children: [
            const SizedBox(height: 44),
            _RescheduledHeader(onBack: () => _returnToAppointments(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        'assets/icons/status/booking_success_check_clean.svg',
                        width: 48,
                        height: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _RescheduledTitle(),
                    const SizedBox(height: 20),
                    Text(
                      'Новое время подтверждено',
                      style: AppTypography.small.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _UpdatedAppointmentCard(appointment: appointment),
                    const SizedBox(height: 20),
                    Text(
                      'Прежняя запись на ${_formatDayMonth(previousStart)} '
                      'отменена. Напомним о новом времени заранее.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'К моим приёмам',
                      onPressed: () => _returnToAppointments(context),
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

class _RescheduledHeader extends StatelessWidget {
  const _RescheduledHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Назад к приёмам',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
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
              'Запись обновлена',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RescheduledTitle extends StatelessWidget {
  const _RescheduledTitle();

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
    stops: [0, 0.19339, 0.3062, 0.38678, 0.46736, 0.53183, 0.67687, 0.8058],
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (_) =>
          _gradient.createShader(const Rect.fromLTWH(0, 0, 345, 36)),
      child: const Text('Приём перенесён', style: AppTypography.title),
    ),
  );
}

class _UpdatedAppointmentCard extends StatelessWidget {
  const _UpdatedAppointmentCard({required this.appointment});

  final DemoPatientAppointment appointment;

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
        Text(
          _formatAppointmentDate(appointment.startsAt),
          style: AppTypography.title.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(appointment.service, style: AppTypography.body),
        Text(appointment.doctor, style: AppTypography.body),
        const SizedBox(height: 12),
        Text(
          appointment.clinic.replaceFirst('пр. ', ''),
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

String _formatAppointmentDate(DateTime date) =>
    '${_formatDayMonth(date)} · ${_formatTime(date)}';

String _formatDayMonth(DateTime date) =>
    '${date.day} ${_monthNameGenitive(date.month)}';

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
