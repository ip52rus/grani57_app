import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_patient_appointments.dart';
import '../../mock_data/demo_patient_documents.dart';
import '../patient_booking/patient_booking_screens.dart';
import '../patient_documents/patient_conclusion_screen.dart';
import '../patient_home/patient_home_screen.dart';
import 'patient_appointment_details_screen.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({
    super.key,
    this.patientId,
    this.patientName = 'Мария Петрова',
    this.bottomNavigation,
    this.showHistoryInitially = false,
  });

  final String? patientId;
  final String patientName;
  final Widget? bottomNavigation;
  final bool showHistoryInitially;

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  late bool _showHistory = widget.showHistoryInitially;
  late final List<DemoPatientAppointment> _upcomingAppointments =
      DemoPatientAppointments.upcomingFor(widget.patientId).toList();

  List<DemoPatientAppointment> get _appointments => _showHistory
      ? DemoPatientAppointments.historyFor(widget.patientId)
      : List.unmodifiable(_upcomingAppointments);

  void _startBooking() {
    Navigator.of(context).push(
      patientBookingRoute(
        context,
        patientId: widget.patientId,
        patientName: widget.patientName,
      ),
    );
  }

  Future<void> _openAppointmentDetails(
    DemoPatientAppointment appointment,
  ) async {
    var currentAppointment = appointment;
    final cancelled = await Navigator.of(context).push<bool>(
      appPageRoute<bool>(
        context,
        builder: (_) => PatientAppointmentDetailsScreen(
          appointment: appointment,
          onAppointmentChanged: (updated) {
            final index = _upcomingAppointments.indexOf(currentAppointment);
            if (index >= 0 && mounted) {
              setState(() => _upcomingAppointments[index] = updated);
              currentAppointment = updated;
            }
          },
        ),
      ),
    );
    if (cancelled == true && mounted) {
      setState(() => _upcomingAppointments.remove(currentAppointment));
    }
  }

  void _openConclusion(DemoPatientAppointment appointment) {
    Navigator.of(context).push(
      appPageRoute<void>(
        context,
        builder: (_) => PatientConclusionScreen(
          document: DemoPatientDocuments.forDate(appointment.startsAt),
          patientName: widget.patientName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.radius28,
    child: Scaffold(
      backgroundColor: _AppointmentsFigma.background,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Column(
          children: [
            const SizedBox(height: 44),
            const _AppointmentsHeader(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 104),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AppointmentsTitle(showHistory: _showHistory),
                        const SizedBox(height: 20),
                        _AppointmentsModeSwitch(
                          showHistory: _showHistory,
                          onChanged: (value) =>
                              setState(() => _showHistory = value),
                        ),
                        const SizedBox(height: 20),
                        if (_appointments.isEmpty)
                          _EmptyAppointments(onStartBooking: _startBooking)
                        else if (_showHistory)
                          _HistoryAppointments(
                            appointments: _appointments,
                            onOpenConclusion: _openConclusion,
                          )
                        else
                          _UpcomingAppointments(
                            appointments: _appointments,
                            onStartBooking: _startBooking,
                            onOpenDetails: _openAppointmentDetails,
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
                        const PatientBottomNavigation(selectedIndex: 1),
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

class _AppointmentsHeader extends StatelessWidget {
  const _AppointmentsHeader();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 56,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Мои приёмы',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w600,
            color: AppColors.brand,
          ),
        ),
      ),
    ),
  );
}

class _AppointmentsTitle extends StatelessWidget {
  const _AppointmentsTitle({required this.showHistory});

  final bool showHistory;

  @override
  Widget build(BuildContext context) {
    final text = showHistory ? 'История лечения' : 'Ваши приёмы';
    final gradient = showHistory
        ? _AppointmentsFigma.historyGradient
        : _AppointmentsFigma.upcomingGradient;
    return SizedBox(
      height: 36,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) =>
            gradient.createShader(const Rect.fromLTWH(0, 0, 345, 36)),
        child: Text(text, style: AppTypography.title),
      ),
    );
  }
}

class _AppointmentsModeSwitch extends StatefulWidget {
  const _AppointmentsModeSwitch({
    required this.showHistory,
    required this.onChanged,
  });

  final bool showHistory;
  final ValueChanged<bool> onChanged;

  @override
  State<_AppointmentsModeSwitch> createState() =>
      _AppointmentsModeSwitchState();
}

class _AppointmentsModeSwitchState extends State<_AppointmentsModeSwitch> {
  double _dragDistance = 0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final segmentWidth = (constraints.maxWidth - 12) / 2;
      final selectedLeft = widget.showHistory
          ? constraints.maxWidth - segmentWidth - 4
          : 4.0;
      return Semantics(
        label: 'Раздел приёмов',
        value: widget.showHistory ? 'История' : 'Предстоящие',
        child: GestureDetector(
          key: const ValueKey('patient.appointments.mode_switch'),
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => widget.onChanged(
            details.localPosition.dx >= constraints.maxWidth / 2,
          ),
          onHorizontalDragStart: (_) => _dragDistance = 0,
          onHorizontalDragUpdate: (details) =>
              _dragDistance += details.delta.dx,
          onHorizontalDragEnd: (details) {
            final velocity = details.velocity.pixelsPerSecond.dx;
            if (_dragDistance.abs() < 12 && velocity.abs() < 150) return;
            final moveToHistory = _dragDistance > 0 || velocity > 0;
            if (moveToHistory != widget.showHistory) {
              widget.onChanged(moveToHistory);
            }
          },
          child: Container(
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.soft,
              borderRadius: AppRadii.radius12,
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: selectedLeft,
                  top: 4,
                  width: segmentWidth,
                  height: 44,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.radius12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _ModeLabel(
                      label: 'Предстоящие',
                      selected: !widget.showHistory,
                    ),
                    _ModeLabel(label: 'История', selected: widget.showHistory),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Center(
      child: Text(
        label,
        style: AppTypography.small.copyWith(
          color: selected ? AppColors.brand : AppColors.secondary,
        ),
      ),
    ),
  );
}

class _UpcomingAppointments extends StatelessWidget {
  const _UpcomingAppointments({
    required this.appointments,
    required this.onStartBooking,
    required this.onOpenDetails,
  });

  final List<DemoPatientAppointment> appointments;
  final VoidCallback onStartBooking;
  final ValueChanged<DemoPatientAppointment> onOpenDetails;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final appointment in appointments) ...[
        _UpcomingAppointmentCard(
          appointment: appointment,
          onOpenDetails: () => onOpenDetails(appointment),
        ),
        const SizedBox(height: 20),
      ],
      AppButton(
        label: 'Записаться на приём',
        variant: AppButtonVariant.accent,
        onPressed: onStartBooking,
      ),
      const SizedBox(height: 20),
      const _PlansChangedCard(),
    ],
  );
}

class _UpcomingAppointmentCard extends StatelessWidget {
  const _UpcomingAppointmentCard({
    required this.appointment,
    required this.onOpenDetails,
  });

  final DemoPatientAppointment appointment;
  final VoidCallback onOpenDetails;

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
        const _StatusPill(label: 'Подтверждён'),
        const SizedBox(height: 12),
        Text(
          _formatAppointmentDate(appointment.startsAt),
          style: AppTypography.heading.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(appointment.service, style: AppTypography.label),
        const SizedBox(height: 12),
        Text(
          '${appointment.doctor}\n${appointment.clinic}',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Детали приёма',
          variant: AppButtonVariant.secondary,
          onPressed: onOpenDetails,
        ),
      ],
    ),
  );
}

class _HistoryAppointments extends StatelessWidget {
  const _HistoryAppointments({
    required this.appointments,
    required this.onOpenConclusion,
  });

  final List<DemoPatientAppointment> appointments;
  final ValueChanged<DemoPatientAppointment> onOpenConclusion;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<DemoPatientAppointment>>{};
    for (final appointment in appointments) {
      final key =
          '${_monthName(appointment.startsAt.month)} '
          '${appointment.startsAt.year}';
      groups.putIfAbsent(key, () => []).add(appointment);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries) ...[
          Text(
            entry.key,
            style: AppTypography.small.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 20),
          for (final appointment in entry.value) ...[
            _HistoryAppointmentCard(
              appointment: appointment,
              onOpenConclusion: () => onOpenConclusion(appointment),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ],
    );
  }
}

class _HistoryAppointmentCard extends StatelessWidget {
  const _HistoryAppointmentCard({
    required this.appointment,
    required this.onOpenConclusion,
  });

  final DemoPatientAppointment appointment;
  final VoidCallback onOpenConclusion;

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
        if (appointment.showCompletionStatus || appointment.isCancelled) ...[
          _StatusPill(
            label: appointment.isCancelled ? 'Приём отменён' : 'Приём завершён',
            isError: appointment.isCancelled,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          _formatAppointmentDate(appointment.startsAt),
          style: AppTypography.heading.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(appointment.service, style: AppTypography.label),
        const SizedBox(height: 12),
        Text(
          '${appointment.doctor} · ${appointment.clinic}',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Заключение врача',
          variant: AppButtonVariant.secondary,
          onPressed: onOpenConclusion,
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, this.isError = false});

  final String label;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: isError ? const Color(0xFFFFE8EA) : AppColors.successBg,
      borderRadius: AppRadii.radiusFull,
    ),
    child: Text(
      label,
      style: AppTypography.caption.copyWith(
        color: isError ? AppColors.error : AppColors.success,
      ),
    ),
  );
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments({required this.onStartBooking});

  final VoidCallback onStartBooking;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 52),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.soft,
          borderRadius: AppRadii.radius20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/icons/status/empty_appointments_clean.svg',
              width: 48,
              height: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Пока нет записей',
              style: AppTypography.title.copyWith(color: AppColors.brand),
            ),
            const SizedBox(height: 12),
            Text(
              'Выберите клинику и удобное время.\nВсё остальное мы подготовим.',
              style: AppTypography.body.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Записаться на приём',
              variant: AppButtonVariant.accent,
              onPressed: onStartBooking,
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const _BookingHelpCard(),
    ],
  );
}

class _BookingHelpCard extends StatelessWidget {
  const _BookingHelpCard();

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => _showFutureFeature(
      context,
      'Звонок в клинику будет подключён следующим этапом',
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.radius20,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/actions/phone_clean.svg',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Нужна помощь с записью?', style: AppTypography.label),
                const SizedBox(height: 4),
                Text(
                  'Позвоните в клинику',
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
  );
}

class _PlansChangedCard extends StatelessWidget {
  const _PlansChangedCard();

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
          'Планы изменились?',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(
          'Откройте запись, чтобы выбрать другое время или отменить приём.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

void _showFutureFeature(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _formatAppointmentDate(DateTime date) =>
    '${date.day} ${_monthNameGenitive(date.month)} · '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

String _monthName(int month) => const [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
][month - 1];

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

abstract final class _AppointmentsFigma {
  static const background = Color(0xFFF5F8FD);

  static const upcomingGradient = LinearGradient(
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
    stops: [0, 0.144, 0.228, 0.288, 0.348, 0.396, 0.504, 0.6],
  );

  static const historyGradient = LinearGradient(
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
    stops: [0, 0.18643, 0.29519, 0.37287, 0.45055, 0.5127, 0.65252, 0.77681],
  );
}
