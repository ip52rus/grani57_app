import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../mock_data/demo_appointment.dart';
import '../../mock_data/demo_asset_paths.dart';
import '../../mock_data/demo_employees.dart';
import 'doctor_schedule_formatters.dart';

class DoctorAppointmentDetailScreen extends StatelessWidget {
  const DoctorAppointmentDetailScreen({required this.appointment, super.key});

  final DemoAppointment appointment;

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
            _Header(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: AppTypography.title.copyWith(
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${appointment.startsAt.day} '
                      '${doctorMonthGenitive(appointment.startsAt.month)} · '
                      '${doctorTimeRange(appointment.startsAt, appointment.endsAt)}',
                      style: AppTypography.small.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _AppointmentDataCard(appointment: appointment),
                    const SizedBox(height: 20),
                    const _AppointmentInfoCard(),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: AppButton(
                key: const ValueKey('doctor.appointment.backToSchedule'),
                label: 'Вернуться к расписанию',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              key: const ValueKey('doctor.appointment.back'),
              padding: EdgeInsets.zero,
              onPressed: onBack,
              icon: Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  DemoAssetPaths.doctorBack,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Запись на приём',
            style: AppTypography.label.copyWith(color: AppColors.brand),
          ),
        ],
      ),
    ),
  );
}

class _AppointmentDataCard extends StatelessWidget {
  const _AppointmentDataCard({required this.appointment});

  final DemoAppointment appointment;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      children: [
        _DataRow(label: 'Услуга', value: appointment.serviceTitle),
        const SizedBox(height: 12),
        _DataRow(
          label: 'Клиника и кабинет',
          value: '${appointment.clinic} · ${appointment.cabinet}',
        ),
        const SizedBox(height: 12),
        _DataRow(label: 'Врач', value: DemoEmployees.doctor.name),
        const SizedBox(height: 12),
        _DataRow(label: 'Тип визита', value: appointment.visitType),
        const SizedBox(height: 12),
        _DataRow(label: 'Комментарий к записи', value: appointment.comment),
      ],
    ),
  );
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.body.copyWith(color: AppColors.text)),
      ],
    ),
  );
}

class _AppointmentInfoCard extends StatelessWidget {
  const _AppointmentInfoCard();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          DemoAssetPaths.doctorCalendarInfo,
          width: 24,
          height: 24,
        ),
        const SizedBox(height: 12),
        Text(
          'Ваш приём',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(
          'Изменения времени и отмены\n'
          'отображаются в расписании автоматически.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}
