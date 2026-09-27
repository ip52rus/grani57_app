import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/admin_demo_store.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_appointment.dart';
import '../../mock_data/demo_admin_models.dart';
import '../../mock_data/demo_asset_paths.dart';
import '../../mock_data/demo_employees.dart';
import '../../mock_data/demo_schedule.dart';
import '../patient_auth/patient_phone_login_screen.dart';
import 'doctor_appointment_detail_screen.dart';
import 'doctor_schedule_formatters.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({
    super.key,
    this.sessionStore,
    this.initialDate,
    this.onRefresh,
    this.doctorId,
    this.doctorName,
    this.doctorStore,
  });

  final DemoSessionStore? sessionStore;
  final DateTime? initialDate;
  final VoidCallback? onRefresh;
  final String? doctorId;
  final String? doctorName;
  final AdminDemoStore? doctorStore;

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  late final DemoSessionStore _sessionStore;
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  String _updatedAt = '09:41';
  DemoDoctorProfile? _doctorProfile;

  @override
  void initState() {
    super.initState();
    _sessionStore = widget.sessionStore ?? DemoSessionStore();
    _selectedDate = widget.initialDate ?? DemoSchedule.selectedWorkday;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _loadDoctorProfile();
  }

  @override
  Widget build(BuildContext context) {
    final doctorId = widget.doctorId ?? DemoEmployees.doctor.id;
    final appointments = DemoSchedule.appointmentsForDay(
      _selectedDate,
      doctorId: doctorId,
    );
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
              _ScheduleHeader(onSignOut: _signOut),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctorName ??
                            _doctorProfile?.name ??
                            DemoEmployees.doctor.name,
                        style: AppTypography.title.copyWith(
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _doctorSpecialty,
                        style: AppTypography.small.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _DoctorCalendar(
                        displayedMonth: _displayedMonth,
                        selectedDate: _selectedDate,
                        doctorId: doctorId,
                        onPreviousMonth: () => _changeMonth(-1),
                        onNextMonth: () => _changeMonth(1),
                        onDateSelected: _selectDate,
                      ),
                      const SizedBox(height: 20),
                      _SelectedDateHeader(date: _selectedDate),
                      const SizedBox(height: 20),
                      const _ClinicBadge(),
                      const SizedBox(height: 20),
                      Text(
                        _summary(appointments),
                        key: const ValueKey('doctor.schedule.summary'),
                        style: AppTypography.small.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (appointments.isEmpty)
                        const _EmptyScheduleCard()
                      else
                        for (
                          var index = 0;
                          index < appointments.length;
                          index++
                        ) ...[
                          _AppointmentCard(
                            appointment: appointments[index],
                            highlighted:
                                appointments[index].id ==
                                DemoSchedule.featuredAppointment.id,
                            onTap: () => _openAppointment(appointments[index]),
                          ),
                          if (index != appointments.length - 1)
                            const SizedBox(height: 20),
                        ],
                    ],
                  ),
                ),
              ),
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Semantics(
                  value: 'Обновлено в $_updatedAt',
                  child: AppButton(
                    key: const ValueKey('doctor.schedule.refresh'),
                    label: 'Обновить расписание',
                    variant: AppButtonVariant.secondary,
                    onPressed: _refresh,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + offset,
      );
      _selectedDate = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    });
  }

  void _selectDate(DateTime date) => setState(() => _selectedDate = date);

  String get _doctorSpecialty {
    final description = _doctorProfile?.description;
    if (description == null || description.isEmpty) {
      return 'Стоматолог-терапевт';
    }
    return description.split('·').first.trim();
  }

  Future<void> _loadDoctorProfile() async {
    final store = widget.doctorStore ?? AdminDemoStore();
    await store.initialize();
    final profile = store.doctorById(
      widget.doctorId ?? DemoEmployees.doctor.id,
    );
    if (!mounted) return;
    setState(() => _doctorProfile = profile);
  }

  Future<void> _openAppointment(DemoAppointment appointment) async {
    await Navigator.of(context).push<void>(
      appPageRoute<void>(
        context,
        builder: (_) => DoctorAppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  void _refresh() {
    final now = TimeOfDay.now();
    setState(() {
      _updatedAt =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
    });
    widget.onRefresh?.call();
  }

  Future<void> _signOut() async {
    await _sessionStore.clearSession();
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil<void>(
      appPageRoute<void>(
        context,
        builder: (_) => PatientPhoneLoginScreen(sessionStore: _sessionStore),
      ),
      (_) => false,
    );
  }

  String _summary(List<DemoAppointment> appointments) {
    if (appointments.isEmpty) return 'Приёмов нет';
    final minutes = appointments.fold<int>(
      0,
      (sum, appointment) =>
          sum + appointment.endsAt.difference(appointment.startsAt).inMinutes,
    );
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    final duration = remainder == 0 ? '$hours ч' : '$hours ч $remainder мин';
    return '${appointments.length} приёма · $duration';
  }
}

class _ScheduleHeader extends StatelessWidget {
  const _ScheduleHeader({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Кабинет врача',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
          TextButton(
            key: const ValueKey('doctor.schedule.signOut'),
            onPressed: onSignOut,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brand,
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 44),
              overlayColor: Colors.transparent,
            ),
            child: Text(
              'Выйти',
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DoctorCalendar extends StatelessWidget {
  const _DoctorCalendar({
    required this.displayedMonth,
    required this.selectedDate,
    required this.doctorId,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final String doctorId;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      displayedMonth.year,
      displayedMonth.month,
    );
    final leading = first.weekday - 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.radius20,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MonthButton(
                key: const ValueKey('doctor.calendar.previousMonth'),
                asset: DemoAssetPaths.doctorChevronLeft,
                onPressed: onPreviousMonth,
              ),
              SizedBox(
                width: 177,
                child: Text(
                  '${doctorMonthName(displayedMonth.month)} '
                  '${displayedMonth.year}',
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(
                    color: AppColors.brand,
                    fontSize: 18,
                  ),
                ),
              ),
              _MonthButton(
                key: const ValueKey('doctor.calendar.nextMonth'),
                asset: DemoAssetPaths.doctorChevronRight,
                onPressed: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'])
                _WeekdayLabel(day),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 246,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var week = 0; week < 6; week++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var weekday = 0; weekday < 7; weekday++)
                        _calendarCell(
                          index: week * 7 + weekday,
                          leading: leading,
                          daysInMonth: daysInMonth,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _CalendarLegend(),
        ],
      ),
    );
  }

  Widget _calendarCell({
    required int index,
    required int leading,
    required int daysInMonth,
  }) {
    final day = index - leading + 1;
    if (day < 1 || day > daysInMonth) {
      return const SizedBox(width: 36, height: 36);
    }
    final date = DateTime(displayedMonth.year, displayedMonth.month, day);
    return _CalendarDay(
      key: ValueKey('doctor.calendar.day.$day'),
      day: day,
      selected: DemoSchedule.isSameDay(date, selectedDate),
      hasAppointments: DemoSchedule.hasAppointments(date, doctorId: doctorId),
      onPressed: () => onDateSelected(date),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.asset, required this.onPressed, super.key});

  final String asset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 40,
    child: IconButton(
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.soft,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.radius12),
      ),
      onPressed: onPressed,
      icon: SvgPicture.asset(asset, width: 20, height: 20),
    ),
  );
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 36,
    height: 20,
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(
        color: AppColors.secondary,
        fontSize: 12,
      ),
    ),
  );
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.selected,
    required this.hasAppointments,
    required this.onPressed,
    super.key,
  });

  final int day;
  final bool selected;
  final bool hasAppointments;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 36,
    child: TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadii.radius12),
        ),
        backgroundColor: WidgetStatePropertyAll(
          selected
              ? AppColors.brand
              : hasAppointments
              ? AppColors.soft
              : AppColors.surface,
        ),
        side: WidgetStatePropertyAll(
          hasAppointments && !selected
              ? const BorderSide(color: AppColors.border)
              : BorderSide.none,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$day',
            style: AppTypography.small.copyWith(
              color: selected ? AppColors.onBrand : AppColors.brand,
              fontWeight: hasAppointments || selected
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
          if (hasAppointments)
            Positioned(
              bottom: 4,
              child: SvgPicture.asset(
                DemoAssetPaths.doctorAppointmentMarker,
                width: 5,
                height: 5,
              ),
            ),
        ],
      ),
    ),
  );
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(
        child: _LegendItem(color: AppColors.soft, label: 'Есть записи'),
      ),
      SizedBox(width: 16),
      Expanded(
        flex: 2,
        child: _LegendItem(color: AppColors.brand, label: 'Выбранный день'),
      ),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          style: AppTypography.caption.copyWith(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ],
  );
}

class _SelectedDateHeader extends StatelessWidget {
  const _SelectedDateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => const LinearGradient(
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
      stops: [0, .12451, .19713, .24901, .30089, .34239, .43577, .51877],
    ).createShader(bounds),
    child: Text(
      doctorDateLabel(date),
      key: const ValueKey('doctor.schedule.selectedDate'),
      style: AppTypography.heading,
    ),
  );
}

class _EmptyScheduleCard extends StatelessWidget {
  const _EmptyScheduleCard();

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
          DemoAssetPaths.doctorEmptyCalendar,
          width: 44,
          height: 44,
        ),
        const SizedBox(height: 12),
        const _EmptyScheduleGradientLine(
          text: 'На этот день',
          stops: [0, .15580, .24669, .31161, .37652, .42846, .54531, .64918],
        ),
        const _EmptyScheduleGradientLine(
          text: 'записей нет',
          stops: [0, .14793, .23423, .29587, .35751, .40682, .51777, .61639],
        ),
        const SizedBox(height: 12),
        Text(
          'Выберите другую дату, чтобы\nпосмотреть своё расписание.',
          style: AppTypography.body.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _EmptyScheduleGradientLine extends StatelessWidget {
  const _EmptyScheduleGradientLine({required this.text, required this.stops});

  final String text;
  final List<double> stops;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => LinearGradient(
      colors: const [
        AppColors.brand,
        AppColors.brand,
        AppColors.sky,
        Color(0xFFA46BD5),
        AppColors.coral,
        AppColors.accent,
        AppColors.brand,
        AppColors.brand,
      ],
      stops: stops,
    ).createShader(bounds),
    child: Text(text, style: AppTypography.title),
  );
}

class _ClinicBadge extends StatelessWidget {
  const _ClinicBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: BorderRadius.all(Radius.circular(999)),
    ),
    child: Text(
      DemoSchedule.clinic,
      style: AppTypography.caption.copyWith(color: AppColors.brand),
    ),
  );
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.highlighted,
    required this.onTap,
  });

  final DemoAppointment appointment;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: AppRadii.radius20,
    child: InkWell(
      key: ValueKey('doctor.appointment.${appointment.id}'),
      onTap: onTap,
      borderRadius: AppRadii.radius20,
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: AppRadii.radius20,
          border: highlighted ? Border.all(color: AppColors.brand) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    doctorTimeRange(appointment.startsAt, appointment.endsAt),
                    style: AppTypography.small.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                _AppointmentStatusBadge(appointment: appointment),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.patientName,
              style: AppTypography.heading.copyWith(color: AppColors.brand),
            ),
            const SizedBox(height: 8),
            Text(
              appointment.serviceTitle,
              style: AppTypography.small.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AppointmentStatusBadge extends StatelessWidget {
  const _AppointmentStatusBadge({required this.appointment});

  final DemoAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final isCompleted = appointment.statusLabel == 'Завершён';
    return Container(
      key: ValueKey('doctor.appointment.status.${appointment.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFFFE8EA) : AppColors.successBg,
        borderRadius: AppRadii.radiusFull,
      ),
      child: Text(
        appointment.statusLabel,
        style: AppTypography.caption.copyWith(
          color: isCompleted ? AppColors.error : AppColors.success,
        ),
      ),
    );
  }
}
