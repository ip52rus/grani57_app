import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_patient_appointments.dart';
import '../patient_booking/patient_booking_screens.dart';
import 'patient_appointment_rescheduled_screen.dart';

class PatientAppointmentRescheduleScreen extends StatefulWidget {
  const PatientAppointmentRescheduleScreen({
    required this.appointment,
    this.onConfirmed,
    super.key,
  });

  final DemoPatientAppointment appointment;
  final ValueChanged<DemoPatientAppointment>? onConfirmed;

  @override
  State<PatientAppointmentRescheduleScreen> createState() =>
      _PatientAppointmentRescheduleScreenState();
}

class _PatientAppointmentRescheduleScreenState
    extends State<PatientAppointmentRescheduleScreen> {
  late DateTime _selectedDate = DateTime(
    widget.appointment.startsAt.year,
    widget.appointment.startsAt.month,
    widget.appointment.startsAt.day + 1,
  );
  late DateTime _visibleMonth = DateTime(
    _selectedDate.year,
    _selectedDate.month,
  );
  String _selectedTime = '12:00';

  DateTime get _selectedStart {
    final parts = _selectedTime.split(':');
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  void _confirmReschedule(BuildContext context) {
    final updated = widget.appointment.copyWith(startsAt: _selectedStart);
    widget.onConfirmed?.call(updated);
    Navigator.of(context).pushAndRemoveUntil<void>(
      appPageRoute<void>(
        context,
        builder: (_) => PatientAppointmentRescheduledScreen(
          appointment: updated,
          previousStart: widget.appointment.startsAt,
        ),
      ),
      (route) => route.isFirst,
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
            const _RescheduleHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _RescheduleTitle(),
                    const SizedBox(height: 20),
                    _CurrentAppointmentCard(appointment: widget.appointment),
                    const SizedBox(height: 20),
                    PatientBookingCalendar(
                      visibleMonth: _visibleMonth,
                      selectedDate: _selectedDate,
                      onMonthChanged: (month) =>
                          setState(() => _visibleMonth = month),
                      onSelected: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                    const SizedBox(height: 20),
                    const _FreeTimeTitle(),
                    const SizedBox(height: 12),
                    PatientBookingTimeGrid(
                      selected: _selectedTime,
                      onSelected: (time) =>
                          setState(() => _selectedTime = time),
                    ),
                    const SizedBox(height: 20),
                    _NewAppointmentCard(
                      selectedDate: _selectedDate,
                      selectedTime: _selectedTime,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 88,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              color: AppColors.surface,
              child: AppButton(
                label: 'Подтвердить перенос',
                onPressed: () => _confirmReschedule(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RescheduleHeader extends StatelessWidget {
  const _RescheduleHeader();

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
              'Перенести приём',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RescheduleTitle extends StatelessWidget {
  const _RescheduleTitle();

  @override
  Widget build(BuildContext context) => const _GradientText(
    'Выберите новое\nвремя',
    style: AppTypography.title,
    gradient: _titleGradient,
    shaderHeight: 72,
  );
}

class _FreeTimeTitle extends StatelessWidget {
  const _FreeTimeTitle();

  @override
  Widget build(BuildContext context) => const _GradientText(
    'Свободное время',
    style: AppTypography.heading,
    gradient: _freeTimeGradient,
    shaderHeight: 28,
  );
}

class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text, {
    required this.style,
    required this.gradient,
    required this.shaderHeight,
  });

  final String text;
  final TextStyle style;
  final LinearGradient gradient;
  final double shaderHeight;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (_) =>
        gradient.createShader(Rect.fromLTWH(0, 0, 345, shaderHeight)),
    child: Text(text, style: style),
  );
}

class _CurrentAppointmentCard extends StatelessWidget {
  const _CurrentAppointmentCard({required this.appointment});

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
          'Сейчас',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 4),
        Text(
          _formatAppointmentDate(appointment.startsAt),
          style: AppTypography.body,
        ),
        const SizedBox(height: 12),
        Text(
          '${appointment.doctor} · ${appointment.clinic.replaceFirst('пр. ', '')}',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _NewAppointmentCard extends StatelessWidget {
  const _NewAppointmentCard({
    required this.selectedDate,
    required this.selectedTime,
  });

  final DateTime selectedDate;
  final String selectedTime;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Новое время',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 4),
        Text(
          '${selectedDate.day} ${_monthName(selectedDate.month)} · '
          '$selectedTime',
          style: AppTypography.body,
        ),
        const SizedBox(height: 12),
        Text(
          'Текущая запись сохранится, пока\nвы не подтвердите перенос.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

String _formatAppointmentDate(DateTime date) =>
    '${date.day} ${_monthName(date.month)} · '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

String _monthName(int month) => const [
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

const _titleGradient = LinearGradient(
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

const _freeTimeGradient = LinearGradient(
  colors: [
    AppColors.brand,
    AppColors.brand,
    AppColors.sky,
    Color(0xFFA46BD5),
    AppColors.coral,
    AppColors.accent,
    AppColors.accent,
  ],
  stops: [0, .23711, .31055, .37428, .44218, .51014, 1],
);
