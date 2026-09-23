import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/navigation/external_route_launcher.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_asset_paths.dart';
import '../../mock_data/demo_patient_appointments.dart';
import 'patient_appointment_cancel_screen.dart';
import 'patient_appointment_reschedule_screen.dart';

class PatientAppointmentDetailsScreen extends StatefulWidget {
  const PatientAppointmentDetailsScreen({
    required this.appointment,
    this.onShowRoute,
    this.onReschedule,
    this.onCancel,
    this.onAppointmentChanged,
    super.key,
  });

  final DemoPatientAppointment appointment;
  final VoidCallback? onShowRoute;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final ValueChanged<DemoPatientAppointment>? onAppointmentChanged;

  @override
  State<PatientAppointmentDetailsScreen> createState() =>
      _PatientAppointmentDetailsScreenState();
}

class _PatientAppointmentDetailsScreenState
    extends State<PatientAppointmentDetailsScreen> {
  late DemoPatientAppointment _appointment = widget.appointment;

  void _applyAppointmentChange(DemoPatientAppointment updated) {
    if (mounted) setState(() => _appointment = updated);
    widget.onAppointmentChanged?.call(updated);
  }

  Future<void> _openCancellation(BuildContext context) async {
    if (widget.onCancel case final callback?) {
      callback();
      return;
    }

    final result = await Navigator.of(context).push<Object?>(
      appPageRoute<Object?>(
        context,
        builder: (_) => PatientAppointmentCancelScreen(
          appointment: _appointment,
          onChooseAnotherTime: widget.onReschedule,
          onAppointmentChanged: _applyAppointmentChange,
        ),
      ),
    );
    if (result == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _openReschedule(BuildContext context) async {
    if (widget.onReschedule case final callback?) {
      callback();
      return;
    }

    await Navigator.of(context).push<void>(
      appPageRoute<void>(
        context,
        builder: (_) => PatientAppointmentRescheduleScreen(
          appointment: _appointment,
          onConfirmed: _applyAppointmentChange,
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
            const _DetailsHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: _ConfirmedPill(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _formatAppointmentDate(_appointment.startsAt),
                      style: AppTypography.title.copyWith(
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DoctorCard(doctor: _appointment.doctor),
                    const SizedBox(height: 20),
                    _AppointmentInfoCard(appointment: _appointment),
                    const SizedBox(height: 20),
                    _RouteCard(
                      onTap:
                          widget.onShowRoute ??
                          () => launchDrivingRoute(
                            latitude: 60.053122,
                            longitude: 30.325969,
                          ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Перенести приём',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _openReschedule(context),
                    ),
                    const SizedBox(height: 20),
                    _CancelButton(onPressed: () => _openCancellation(context)),
                    const SizedBox(height: 20),
                    Text(
                      'Возьмите с собой паспорт. Если опаздываете, '
                      'пожалуйста, позвоните в клинику.',
                      style: AppTypography.small.copyWith(
                        color: AppColors.secondary,
                      ),
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

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader();

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
              'Детали приёма',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ConfirmedPill extends StatelessWidget {
  const _ConfirmedPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: const BoxDecoration(
      color: AppColors.successBg,
      borderRadius: AppRadii.radiusFull,
    ),
    child: Text(
      'Подтверждён',
      style: AppTypography.caption.copyWith(color: AppColors.success),
    ),
  );
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final String doctor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24082152),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            DemoAssetPaths.doctorAnnaSmirnova,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor, style: AppTypography.label),
              const SizedBox(height: 4),
              Text(
                'Стоматолог-терапевт',
                style: AppTypography.small.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AppointmentInfoCard extends StatelessWidget {
  const _AppointmentInfoCard({required this.appointment});

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
        const _InfoLabel('Услуга'),
        const SizedBox(height: 4),
        Text(appointment.service, style: AppTypography.body),
        const SizedBox(height: 12),
        const _InfoLabel('Клиника'),
        const SizedBox(height: 4),
        Text(appointment.clinic, style: AppTypography.body),
      ],
    ),
  );
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: AppTypography.small.copyWith(color: AppColors.secondary),
  );
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Как добраться. Показать маршрут',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Как добраться', style: AppTypography.label),
                  const SizedBox(height: 4),
                  Text(
                    'Показать маршрут',
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

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Отменить запись',
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
          'Отменить запись',
          style: AppTypography.label.copyWith(color: AppColors.error),
        ),
      ),
    ),
  );
}

String _formatAppointmentDate(DateTime date) =>
    '${date.day} ${_monthNameGenitive(date.month)} · '
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
