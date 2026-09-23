import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/navigation/app_page_route.dart';
import '../patient_notifications/patient_notification_permission.dart';
import '../patient_notifications/patient_notification_screens.dart';
import '../patient_notifications/patient_notification_store.dart';

Route<void> patientBookingRoute(
  BuildContext context, {
  String? patientId,
  String patientName = 'Мария Петрова',
}) => appPageRoute<void>(
  context,
  builder: (_) => PatientBookingClinicScreen(
    draft: BookingDraft(patientId: patientId, patientName: patientName),
  ),
);

enum BookingSubmissionResult { success, offline, timeUnavailable }

typedef BookingSubmitter =
    Future<BookingSubmissionResult> Function(BookingDraft draft);

const _bookingDateTimeRouteName = '/patient-booking/date-time';

class BookingDraft {
  const BookingDraft({
    this.service = 'Лечение зубов',
    this.serviceDescription = 'Консультация терапевта от 1000 р.',
    this.doctor = 'Анна Смирнова',
    this.doctorSpecialty = 'Стоматолог-терапевт',
    this.day = 14,
    this.month = 9,
    this.year = 2026,
    this.time = '10:30',
    this.patientId,
    this.patientName = 'Мария Петрова',
  });

  final String service;
  final String serviceDescription;
  final String doctor;
  final String doctorSpecialty;
  final int day;
  final int month;
  final int year;
  final String time;
  final String? patientId;
  final String patientName;

  BookingDraft copyWith({
    String? service,
    String? serviceDescription,
    String? doctor,
    String? doctorSpecialty,
    int? day,
    int? month,
    int? year,
    String? time,
    String? patientId,
    String? patientName,
  }) => BookingDraft(
    service: service ?? this.service,
    serviceDescription: serviceDescription ?? this.serviceDescription,
    doctor: doctor ?? this.doctor,
    doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
    day: day ?? this.day,
    month: month ?? this.month,
    year: year ?? this.year,
    time: time ?? this.time,
    patientId: patientId ?? this.patientId,
    patientName: patientName ?? this.patientName,
  );
}

class PatientBookingClinicScreen extends StatelessWidget {
  const PatientBookingClinicScreen({
    this.draft = const BookingDraft(),
    super.key,
  });

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) => _BookingPage(
    step: 1,
    title: 'Выберите клинику',
    subtitle: 'Санкт-Петербург',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ClinicCard(
          available: true,
          title: 'На Просвещения',
          address: 'пр. Просвещения, 15',
          details: 'м. Проспект Просвещения\nЕжедневно · 09:00–21:00',
          onSelect: () => Navigator.of(context).push(
            appPageRoute<void>(
              context,
              builder: (_) => PatientBookingServiceScreen(draft: draft),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _ClinicCard(
          available: false,
          title: 'На Большеохтинском',
          address: 'Большеохтинский пр., 12',
          details:
              'м. Ладожская\nм. Новочеркасская\nЕжедневно · 09:00–21:00\nЗапись появится после открытия',
        ),
        const SizedBox(height: 20),
        const _MapCard(),
      ],
    ),
  );
}

class PatientBookingServiceScreen extends StatefulWidget {
  const PatientBookingServiceScreen({
    this.draft = const BookingDraft(),
    super.key,
  });
  final BookingDraft draft;

  @override
  State<PatientBookingServiceScreen> createState() =>
      _PatientBookingServiceScreenState();
}

class _PatientBookingServiceScreenState
    extends State<PatientBookingServiceScreen> {
  bool _byDoctor = false;
  late BookingDraft _draft = widget.draft;

  @override
  Widget build(BuildContext context) => _BookingPage(
    step: 2,
    title: 'Как записаться?',
    titleGradient: _bookingGradient,
    titleShaderWidth: 255,
    subtitle: 'На Просвещения · изменить клинику',
    footer: _BookingFooter(
      label: 'Выбрать дату и время',
      onPressed: () => Navigator.of(context).push(
        appPageRoute<void>(
          context,
          builder: (_) => PatientBookingDateTimeScreen(draft: _draft),
          settings: const RouteSettings(name: _bookingDateTimeRouteName),
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BookingModeSwitch(
          byDoctor: _byDoctor,
          onChanged: (value) => setState(() => _byDoctor = value),
        ),
        const SizedBox(height: 20),
        _GradientHeading(
          _byDoctor ? 'Выберите врача' : 'Выберите услугу',
          shaderWidth: _byDoctor ? 159 : 166,
        ),
        const SizedBox(height: 16),
        if (_byDoctor)
          _DoctorList(
            selected: _draft.doctor,
            onSelected: (doctor, specialty) => setState(
              () => _draft = _draft.copyWith(
                doctor: doctor,
                doctorSpecialty: specialty,
              ),
            ),
          )
        else
          _ServiceList(
            selected: _draft.service,
            onSelected: (service, description) => setState(
              () => _draft = _draft.copyWith(
                service: service,
                serviceDescription: description,
              ),
            ),
          ),
        if (!_byDoctor) ...[const SizedBox(height: 16), const _TariffNote()],
      ],
    ),
  );
}

class PatientBookingDateTimeScreen extends StatefulWidget {
  const PatientBookingDateTimeScreen({required this.draft, super.key});
  final BookingDraft draft;
  @override
  State<PatientBookingDateTimeScreen> createState() =>
      _PatientBookingDateTimeScreenState();
}

class _PatientBookingDateTimeScreenState
    extends State<PatientBookingDateTimeScreen> {
  late BookingDraft _draft = widget.draft;
  late DateTime _visibleMonth = DateTime(_draft.year, _draft.month);
  @override
  Widget build(BuildContext context) => _BookingPage(
    step: 3,
    title: 'Когда Вам удобно?',
    titleGradient: _dateTimeTitleGradient,
    titleShaderWidth: 345,
    subtitle: '${_draft.service.split(' ').first} · Просвещения, 15',
    footer: _BookingFooter(
      label: 'Продолжить',
      onPressed: () => Navigator.of(context).push(
        appPageRoute<void>(
          context,
          builder: (_) => PatientBookingConfirmationScreen(draft: _draft),
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PatientBookingCalendar(
          visibleMonth: _visibleMonth,
          selectedDate: DateTime(_draft.year, _draft.month, _draft.day),
          onMonthChanged: (month) => setState(() => _visibleMonth = month),
          onSelected: (date) => setState(
            () => _draft = _draft.copyWith(
              day: date.day,
              month: date.month,
              year: date.year,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _GradientHeading(
          'Свободное время',
          gradient: _freeTimeGradient,
          shaderWidth: 345,
        ),
        const SizedBox(height: 12),
        PatientBookingTimeGrid(
          selected: _draft.time,
          onSelected: (time) =>
              setState(() => _draft = _draft.copyWith(time: time)),
        ),
        const SizedBox(height: 20),
        _DoctorSummary(draft: _draft),
        const SizedBox(height: 20),
        _ChoiceCard(draft: _draft),
      ],
    ),
  );
}

class PatientBookingConfirmationScreen extends StatefulWidget {
  const PatientBookingConfirmationScreen({
    required this.draft,
    this.submitBooking,
    super.key,
  });

  final BookingDraft draft;

  /// The backend adapter can return one of the three Figma result states.
  /// Demo mode completes successfully until the real API is connected.
  final BookingSubmitter? submitBooking;

  @override
  State<PatientBookingConfirmationScreen> createState() =>
      _PatientBookingConfirmationScreenState();
}

class _PatientBookingConfirmationScreenState
    extends State<PatientBookingConfirmationScreen> {
  var _isSubmitting = false;
  var _demoSubmissionAttempts = 0;

  Future<BookingSubmissionResult> _submit(BookingDraft draft) async {
    final submitBooking = widget.submitBooking;
    if (submitBooking == null) {
      if (draft.patientId == 'patient_003') {
        _demoSubmissionAttempts += 1;
        return _demoSubmissionAttempts == 1
            ? BookingSubmissionResult.offline
            : BookingSubmissionResult.timeUnavailable;
      }
      return BookingSubmissionResult.success;
    }
    try {
      return await submitBooking(draft);
    } catch (_) {
      return BookingSubmissionResult.offline;
    }
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final result = await _submit(widget.draft);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _openSubmissionResult(
      context,
      result: result,
      draft: widget.draft,
      submitBooking: _submit,
    );
  }

  @override
  Widget build(BuildContext context) => _BookingPage(
    step: 4,
    title: 'Всё верно?',
    titleGradient: _confirmationGradient,
    titleShaderWidth: 345,
    subtitle: 'Проверьте детали перед записью',
    footer: _BookingFooter(
      label: 'Подтвердить запись',
      onPressed: _onSubmit,
      isLoading: _isSubmitting,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConfirmationCard(draft: widget.draft),
        const SizedBox(height: 20),
        const _ReminderCard(),
        const SizedBox(height: 20),
        Text(
          'Запись можно перенести или отменить\nв разделе «Приёмы».',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class PatientBookingTimeUnavailableScreen extends StatelessWidget {
  const PatientBookingTimeUnavailableScreen({
    required this.draft,
    this.onContactClinic,
    super.key,
  });

  final BookingDraft draft;
  final VoidCallback? onContactClinic;

  void _chooseDifferentTime(BuildContext context) {
    final navigator = Navigator.of(context);
    final fallbackRoute = appPageRoute<void>(
      context,
      settings: const RouteSettings(name: _bookingDateTimeRouteName),
      builder: (_) => PatientBookingDateTimeScreen(draft: draft),
    );
    var foundDateTimeStep = false;
    navigator.popUntil((route) {
      if (route.settings.name == _bookingDateTimeRouteName) {
        foundDateTimeStep = true;
        return true;
      }
      return route.isFirst;
    });
    if (!foundDateTimeStep) {
      navigator.pushReplacement(fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) => _BookingResultScaffold(
    headerTitle: 'Запись на приём',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: _ResultIcon(
            asset: 'assets/icons/status/booking_clock_clean.svg',
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        const _GradientText(
          'Это время уже занято',
          AppTypography.title,
          gradient: _timeUnavailableGradient,
          shaderWidth: 345,
        ),
        const SizedBox(height: 20),
        Text(
          'Пока вы оформляли запись,\nдругой пациент выбрал этот слот.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 20),
        _ResultInfoCard(
          title: 'Ваш выбор сохранён',
          body: '${draft.service} · ${draft.doctor}\nПросвещения, 15',
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Выбрать другое время',
          onPressed: () => _chooseDifferentTime(context),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Связаться с клиникой',
          variant: AppButtonVariant.secondary,
          onPressed: onContactClinic ?? () => _showClinicContactHint(context),
        ),
      ],
    ),
  );
}

class PatientBookingOfflineScreen extends StatefulWidget {
  const PatientBookingOfflineScreen({
    required this.draft,
    required this.submitBooking,
    this.onContactClinic,
    super.key,
  });

  final BookingDraft draft;
  final BookingSubmitter submitBooking;
  final VoidCallback? onContactClinic;

  @override
  State<PatientBookingOfflineScreen> createState() =>
      _PatientBookingOfflineScreenState();
}

class _PatientBookingOfflineScreenState
    extends State<PatientBookingOfflineScreen> {
  var _isChecking = false;

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    BookingSubmissionResult result;
    try {
      result = await widget.submitBooking(widget.draft);
    } catch (_) {
      result = BookingSubmissionResult.offline;
    }
    if (!mounted) return;
    setState(() => _isChecking = false);
    if (result == BookingSubmissionResult.offline) return;
    _openSubmissionResult(
      context,
      result: result,
      draft: widget.draft,
      submitBooking: widget.submitBooking,
      replaceCurrent: true,
    );
  }

  @override
  Widget build(BuildContext context) => _BookingResultScaffold(
    headerTitle: 'Запись на приём',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 36),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: _ResultIcon(
            asset: 'assets/icons/status/booking_clock_clean.svg',
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        const _OfflineTitle(),
        const SizedBox(height: 20),
        Text(
          'Похоже, нет связи с сервером.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 20),
        const _ResultInfoCard(
          title: 'Мы сохранили ваш выбор',
          body:
              'Проверьте подключение и обновите статус. Пока подтверждение не получено, запись может быть не завершена.',
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Проверить статус',
          isLoading: _isChecking,
          onPressed: _checkStatus,
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Связаться с клиникой',
          variant: AppButtonVariant.secondary,
          onPressed:
              widget.onContactClinic ?? () => _showClinicContactHint(context),
        ),
      ],
    ),
  );
}

class PatientBookingSuccessScreen extends StatelessWidget {
  const PatientBookingSuccessScreen({
    required this.draft,
    this.onEnableReminders,
    this.notificationStore,
    this.notificationPermissionGateway,
    super.key,
  });

  final BookingDraft draft;
  final VoidCallback? onEnableReminders;
  final PatientNotificationStore? notificationStore;
  final PatientNotificationPermissionGateway? notificationPermissionGateway;

  void _goHome(BuildContext context) {
    Navigator.of(context).maybePop();
  }

  Future<void> _openNotificationFlow(BuildContext context) async {
    final patientId = draft.patientId ?? 'demo_patient';
    final store = notificationStore ?? PatientNotificationStore();
    final permissionGateway =
        notificationPermissionGateway ??
        const DevicePatientNotificationPermissionGateway();
    final values = await Future.wait<Object>([
      permissionGateway.status(),
      store.wasPermissionRequested(patientId),
    ]);
    if (!context.mounted) return;

    final permission = values[0] as PatientNotificationPermissionStatus;
    final wasRequested = values[1] as bool;
    final Widget destination =
        permission == PatientNotificationPermissionStatus.disabled &&
            !wasRequested
        ? PatientNotificationPermissionScreen(
            patientId: patientId,
            patientName: draft.patientName,
            store: store,
            permissionGateway: permissionGateway,
          )
        : PatientNotificationSettingsScreen(
            patientId: patientId,
            patientName: draft.patientName,
            store: store,
            permissionGateway: permissionGateway,
          );

    Navigator.of(
      context,
    ).pushReplacement(appPageRoute<void>(context, builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) => _BookingResultScaffold(
    headerTitle: '',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.centerLeft, child: _SuccessIcon()),
        const SizedBox(height: 20),
        const _GradientText(
          'Вы записаны',
          AppTypography.title,
          gradient: _bookingSuccessGradient,
          shaderWidth: 345,
        ),
        const SizedBox(height: 20),
        Text(
          'Ждём вас в клинике «57 ГРАНЕЙ»',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 20),
        _SuccessAppointmentCard(draft: draft),
        const SizedBox(height: 20),
        _ReminderPermissionCard(
          onPressed: onEnableReminders ?? () => _openNotificationFlow(context),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Сейчас не нужно',
          variant: AppButtonVariant.ghost,
          onPressed: () => _goHome(context),
        ),
      ],
    ),
  );
}

void _openSubmissionResult(
  BuildContext context, {
  required BookingSubmissionResult result,
  required BookingDraft draft,
  required BookingSubmitter submitBooking,
  bool replaceCurrent = false,
}) {
  final navigator = Navigator.of(context);
  switch (result) {
    case BookingSubmissionResult.success:
      navigator.pushAndRemoveUntil(
        appPageRoute<void>(
          context,
          builder: (_) => PatientBookingSuccessScreen(draft: draft),
        ),
        (route) => route.isFirst,
      );
      return;
    case BookingSubmissionResult.offline:
      final route = appPageRoute<void>(
        context,
        builder: (_) => PatientBookingOfflineScreen(
          draft: draft,
          submitBooking: submitBooking,
        ),
      );
      if (replaceCurrent) {
        navigator.pushReplacement(route);
      } else {
        navigator.push(route);
      }
      return;
    case BookingSubmissionResult.timeUnavailable:
      navigator.pushReplacement(
        appPageRoute<void>(
          context,
          builder: (_) => PatientBookingTimeUnavailableScreen(draft: draft),
        ),
      );
      return;
  }
}

void _showClinicContactHint(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Контакты клиники будут подключены позже')),
  );
}

class _BookingResultScaffold extends StatelessWidget {
  const _BookingResultScaffold({
    required this.headerTitle,
    required this.child,
  });

  final String headerTitle;
  final Widget child;

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
            _BookingResultHeader(title: headerTitle),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BookingResultHeader extends StatelessWidget {
  const _BookingResultHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          InkResponse(
            onTap: () => Navigator.maybePop(context),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Align(alignment: Alignment.centerLeft, child: _BackIcon()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ResultIcon extends StatelessWidget {
  const _ResultIcon({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(asset, width: size, height: size);
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 80,
    height: 80,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.successBg,
      shape: BoxShape.circle,
    ),
    child: const _ResultIcon(
      asset: 'assets/icons/status/booking_success_check_clean.svg',
      size: 40,
    ),
  );
}

class _OfflineTitle extends StatelessWidget {
  const _OfflineTitle();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _GradientText(
        'Не удалось\nпроверить',
        AppTypography.title,
        shaderWidth: 345,
      ),
      _GradientText(
        'запись',
        AppTypography.title,
        gradient: _offlineLastLineGradient,
        shaderWidth: 345,
      ),
    ],
  );
}

class _ResultInfoCard extends StatelessWidget {
  const _ResultInfoCard({required this.title, required this.body});

  final String title;
  final String body;

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
          title,
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(body, style: AppTypography.body),
      ],
    ),
  );
}

class _SuccessAppointmentCard extends StatelessWidget {
  const _SuccessAppointmentCard({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) => Container(
    height: 136,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${draft.day} ${_monthName(draft.month)} · ${draft.time}',
          style: AppTypography.heading.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text('${draft.service} · ${draft.doctor}', style: AppTypography.body),
        const SizedBox(height: 12),
        Text(
          'пр. Просвещения, 15',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _ReminderPermissionCard extends StatelessWidget {
  const _ReminderPermissionCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    height: 184,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GradientText(
          'Не пропустите приём',
          AppTypography.heading,
          gradient: _reminderTitleGradient,
          shaderWidth: 305,
        ),
        const SizedBox(height: 12),
        Text(
          'Разрешите уведомления — напомним\nо визите заранее.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 12),
        AppButton(label: 'Включить напоминания', onPressed: onPressed),
      ],
    ),
  );
}

class _BookingPage extends StatelessWidget {
  const _BookingPage({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
    this.titleGradient = _bookingGradient,
    this.titleShaderWidth = 345,
    this.footer,
  });
  final int step;
  final String title;
  final String subtitle;
  final Widget child;
  final LinearGradient titleGradient;
  final double titleShaderWidth;
  final Widget? footer;
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
            const _BookingHeader(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        16,
                        24,
                        footer == null ? 24 : 112,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StepChip(step),
                          const SizedBox(height: 20),
                          _GradientTitle(
                            title,
                            gradient: titleGradient,
                            shaderWidth: titleShaderWidth,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: AppTypography.small.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          child,
                        ],
                      ),
                    ),
                  ),
                  if (footer != null)
                    Align(alignment: Alignment.bottomCenter, child: footer!),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BookingHeader extends StatelessWidget {
  const _BookingHeader();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          InkResponse(
            onTap: () => Navigator.maybePop(context),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Align(alignment: Alignment.centerLeft, child: _BackIcon()),
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

class _BackIcon extends StatelessWidget {
  const _BackIcon();
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/icons/actions/news_back.svg',
    width: 24,
    height: 24,
  );
}

class _StepChip extends StatelessWidget {
  const _StepChip(this.step);
  final int step;
  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radiusFull,
    ),
    child: Text(
      'Шаг $step из 4',
      style: AppTypography.caption.copyWith(color: AppColors.brand),
    ),
  );
}

class _GradientTitle extends StatelessWidget {
  const _GradientTitle(
    this.text, {
    required this.gradient,
    required this.shaderWidth,
  });
  final String text;
  final LinearGradient gradient;
  final double shaderWidth;
  @override
  Widget build(BuildContext context) => _GradientText(
    text,
    AppTypography.title,
    shaderWidth: shaderWidth,
    gradient: gradient,
  );
}

class _GradientHeading extends StatelessWidget {
  const _GradientHeading(
    this.text, {
    this.gradient = _bookingGradient,
    this.shaderWidth,
  });
  final String text;
  final LinearGradient gradient;
  final double? shaderWidth;
  @override
  Widget build(BuildContext context) => _GradientText(
    text,
    AppTypography.heading,
    gradient: gradient,
    shaderWidth: shaderWidth,
  );
}

class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text,
    this.style, {
    this.gradient = _bookingGradient,
    this.shaderWidth,
    this.textAlign,
  });
  final String text;
  final TextStyle style;
  final LinearGradient gradient;
  final double? shaderWidth;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => gradient.createShader(
      Rect.fromLTWH(0, 0, shaderWidth ?? bounds.width, bounds.height),
    ),
    child: Text(
      text,
      textAlign: textAlign,
      style: style.copyWith(color: AppColors.brand),
    ),
  );
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({
    required this.available,
    required this.title,
    required this.address,
    required this.details,
    this.onSelect,
  });
  final bool available;
  final String title, address, details;
  final VoidCallback? onSelect;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: available ? Border.all(color: AppColors.brand) : null,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Tag(
          available ? 'Доступна запись' : 'Скоро открытие',
          available ? AppColors.successBg : AppColors.soft,
          available ? AppColors.success : AppColors.secondary,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: AppTypography.heading.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(address, style: AppTypography.body),
        const SizedBox(height: 12),
        Text(
          details,
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        if (available) ...[
          const SizedBox(height: 12),
          AppButton(label: 'Выбрать клинику', onPressed: onSelect),
        ],
      ],
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.background, this.foreground);
  final String text;
  final Color background, foreground;
  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: AppRadii.radiusFull,
    ),
    child: Text(text, style: AppTypography.caption.copyWith(color: foreground)),
  );
}

class _MapCard extends StatelessWidget {
  const _MapCard();
  @override
  Widget build(BuildContext context) => Container(
    height: 104,
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
              Text('Посмотреть на карте', style: AppTypography.label),
              const SizedBox(height: 4),
              Text(
                'Адреса и маршруты',
                style: AppTypography.small.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BookingModeSwitch extends StatefulWidget {
  const _BookingModeSwitch({required this.byDoctor, required this.onChanged});
  final bool byDoctor;
  final ValueChanged<bool> onChanged;

  @override
  State<_BookingModeSwitch> createState() => _BookingModeSwitchState();
}

class _BookingModeSwitchState extends State<_BookingModeSwitch> {
  double _dragDistance = 0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final segmentWidth = (constraints.maxWidth - 12) / 2;
      final selectedLeft = widget.byDoctor
          ? constraints.maxWidth - segmentWidth - 4
          : 4.0;

      return Semantics(
        label: 'Способ записи',
        value: widget.byDoctor ? 'К врачу' : 'По услуге',
        child: GestureDetector(
          key: const ValueKey('patient.booking.mode_switch'),
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => widget.onChanged(
            details.localPosition.dx >= constraints.maxWidth / 2,
          ),
          onHorizontalDragStart: (_) => _dragDistance = 0,
          onHorizontalDragUpdate: (details) {
            _dragDistance += details.delta.dx;
          },
          onHorizontalDragEnd: (details) {
            final velocity = details.velocity.pixelsPerSecond.dx;
            if (_dragDistance.abs() < 12 && velocity.abs() < 150) return;
            final moveToDoctor = _dragDistance > 0 || velocity > 0;
            if (moveToDoctor != widget.byDoctor) {
              widget.onChanged(moveToDoctor);
            }
          },
          child: Container(
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.all(Radius.circular(16)),
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
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModeLabel(
                            label: 'По услуге',
                            active: !widget.byDoctor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _ModeLabel(
                            label: 'К врачу',
                            active: widget.byDoctor,
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
    },
  );
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({required this.label, required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Center(
    child: AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      style: AppTypography.small.copyWith(
        fontWeight: FontWeight.w600,
        color: active ? AppColors.brand : AppColors.secondary,
      ),
      child: Text(label),
    ),
  );
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({required this.selected, required this.onSelected});
  final String selected;
  final void Function(String, String) onSelected;
  static const _items = [
    ('Лечение зубов', 'Консультация терапевта от 1000 р.'),
    ('Имплантация зубов', 'Консультация стоматолога-хирурга от 1000 р.'),
    ('Протезирование', 'Консультация врача-ортопеда от 1000 р.'),
    ('Хирургия', 'Консультация стоматолога-хирурга от 1000 р.'),
    ('Ортодонтия', 'Консультация врача-ортодонта от 1000 р.'),
    ('Лечение десен', 'Консультация пародонтолога от 1000 р.'),
    ('Отбеливание зубов', 'Стоимость услуг по отбеливанию от 5000 р.'),
    ('Рентгенодиагностика', 'Стоимость услуг рентгенодиагностики от 1000 р.'),
    (
      'Детская стоматология',
      'Консультация детского стоматолога-терапевта от 1000 р.',
    ),
  ];
  @override
  Widget build(BuildContext context) => Column(
    children: _items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectRow(
              title: item.$1,
              subtitle: item.$2,
              selected: selected == item.$1,
              onTap: () => onSelected(item.$1, item.$2),
            ),
          ),
        )
        .toList(),
  );
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    child: InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Container(
        height: 72,
        padding: const EdgeInsets.fromLTRB(20, 12, 18, 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.brand : const Color(0xFFBFD3EF),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.small.copyWith(
                      fontWeight: FontWeight.w500,
                      color: selected ? AppColors.brand : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            _Radio(selected: selected),
          ],
        ),
      ),
    ),
  );
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? AppColors.brand : const Color(0xFFBFD3EF),
        width: 2,
      ),
    ),
    child: selected
        ? const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
          )
        : null,
  );
}

class _TariffNote extends StatelessWidget {
  const _TariffNote();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE9F1FF),
      border: Border.all(color: const Color(0xFFC8DAF5)),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.brand,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Text(
            'i',
            style: AppTypography.caption.copyWith(color: AppColors.onBrand),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'В данном разделе приведены базовые тарифы 57 ГРАНЕЙ. Стоимость услуг ведущих специалистов может отличаться от приведенных на сайте.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF496083),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DoctorList extends StatelessWidget {
  const _DoctorList({required this.selected, required this.onSelected});
  final String selected;
  final void Function(String, String) onSelected;
  static const _doctors = [
    (
      'Любой специалист',
      'Ближайший свободный врач',
      'assets/images/booking/doctor_any.png',
    ),
    (
      'Анна Смирнова',
      'Стоматолог-терапевт · стаж 12 лет',
      'assets/images/booking/doctor_anna.png',
    ),
    (
      'Алексей Волков',
      'Стоматолог-терапевт · стаж 9 лет',
      'assets/images/booking/doctor_elena.png',
    ),
    (
      'Елена Кузнецова',
      'Стоматолог-гигиенист · стаж 8 лет',
      'assets/images/booking/doctor_alexey.png',
    ),
  ];
  @override
  Widget build(BuildContext context) => Column(
    children: _doctors
        .map(
          (doctor) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DoctorPick(
              name: doctor.$1,
              specialty: doctor.$2,
              image: doctor.$3,
              selected: selected == doctor.$1,
              onTap: () => onSelected(doctor.$1, doctor.$2),
            ),
          ),
        )
        .toList(),
  );
}

class _DoctorPick extends StatelessWidget {
  const _DoctorPick({
    required this.name,
    required this.specialty,
    required this.image,
    required this.selected,
    required this.onTap,
  });
  final String name, specialty, image;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: AppRadii.radius20,
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadii.radius20,
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.brand : const Color(0xFFC9D6E8),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: AppRadii.radius20,
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                image,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.label.copyWith(color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            _Radio(selected: selected),
          ],
        ),
      ),
    ),
  );
}

class PatientBookingCalendar extends StatelessWidget {
  const PatientBookingCalendar({
    required this.visibleMonth,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onSelected,
    super.key,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: 388,
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      children: [
        Row(
          children: [
            _MonthControl(
              '‹',
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month - 1),
              ),
            ),
            Expanded(child: _MonthTitle(month: visibleMonth)),
            _MonthControl(
              '›',
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month + 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _WeekHeader(),
        const SizedBox(height: 12),
        _MonthGrid(
          month: visibleMonth,
          selectedDate: selectedDate,
          onSelected: onSelected,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${_weekdayName(selectedDate.weekday)}, ${selectedDate.day} ${_monthName(selectedDate.month)}',
            style: AppTypography.small.copyWith(color: AppColors.secondary),
          ),
        ),
      ],
    ),
  );
}

class _MonthControl extends StatelessWidget {
  const _MonthControl(this.symbol, {required this.onPressed});
  final String symbol;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    child: InkWell(
      onTap: onPressed,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFECF3FF),
          border: Border.all(color: const Color(0xFFC8DAF5)),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Text(
          symbol,
          style: const TextStyle(fontSize: 20, color: AppColors.brand),
        ),
      ),
    ),
  );
}

class _MonthTitle extends StatelessWidget {
  const _MonthTitle({required this.month});
  final DateTime month;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 217,
      child: _GradientText(
        '${_monthName(month.month, capitalized: true)} ${month.year}',
        AppTypography.heading,
        gradient: _monthGradient,
        shaderWidth: 217,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDate,
    required this.onSelected,
  });
  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final cells = List<DateTime?>.generate(42, (index) {
      final day = index - (firstWeekday - 1) + 1;
      return day < 1 || day > daysInMonth
          ? null
          : DateTime(month.year, month.month, day);
    });

    return SizedBox(
      height: 212,
      child: Column(
        children: List.generate(
          6,
          (row) => Padding(
            padding: EdgeInsets.only(bottom: row == 5 ? 0 : 4),
            child: Row(
              children: List.generate(7, (column) {
                final date = cells[row * 7 + column];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: column == 6 ? 0 : 4),
                    child: _CalendarDay(
                      date: date,
                      selected: date != null && _sameDate(date, selectedDate),
                      onSelected: date == null ? null : () => onSelected(date),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.selected,
    required this.onSelected,
  });
  final DateTime? date;
  final bool selected;
  final VoidCallback? onSelected;
  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox(height: 32);
    final weekend = date!.weekday >= DateTime.saturday;
    return Material(
      color: selected ? AppColors.brand : const Color(0xFFECF3FF),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        onTap: onSelected,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          height: 32,
          child: Center(
            child: Text(
              '${date!.day}',
              style: AppTypography.caption.copyWith(
                color: selected
                    ? AppColors.onBrand
                    : (weekend ? AppColors.accent : AppColors.secondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: _Week('Пн')),
      Expanded(child: _Week('Вт')),
      Expanded(child: _Week('Ср')),
      Expanded(child: _Week('Чт')),
      Expanded(child: _Week('Пт')),
      Expanded(child: _Week('Сб', true)),
      Expanded(child: _Week('Вс', true)),
    ],
  );
}

class _Week extends StatelessWidget {
  const _Week(this.text, [this.weekend = false]);
  final String text;
  final bool weekend;
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: weekend ? AppColors.accent : AppColors.secondary,
      ),
    ),
  );
}

class PatientBookingTimeGrid extends StatelessWidget {
  const PatientBookingTimeGrid({
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) {
    final times = List.generate(25, (index) {
      final totalMinutes = 9 * 60 + index * 30;
      return '${(totalMinutes ~/ 60).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')}';
    });
    final columns = <Widget>[];
    for (var index = 0; index < times.length; index += 2) {
      columns.add(
        SizedBox(
          width: 109.66,
          child: Column(
            children: [
              _TimeSlot(
                time: times[index],
                selected: selected == times[index],
                onPressed: () => onSelected(times[index]),
              ),
              const SizedBox(height: 8),
              if (index + 1 < times.length)
                _TimeSlot(
                  time: times[index + 1],
                  selected: selected == times[index + 1],
                  onPressed: () => onSelected(times[index + 1]),
                )
              else
                const SizedBox(height: 52),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 112,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          key: const ValueKey('patient.booking.time_slots'),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(children: _withSpacing(columns, 8)),
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  const _TimeSlot({
    required this.time,
    required this.selected,
    required this.onPressed,
  });
  final String time;
  final bool selected;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: AppButton(
      label: time,
      variant: selected ? AppButtonVariant.primary : AppButtonVariant.secondary,
      onPressed: onPressed,
    ),
  );
}

class _DoctorSummary extends StatelessWidget {
  const _DoctorSummary({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Row(
      children: [
        ClipOval(
          child: Image.asset(
            _doctorImageFor(draft.doctor),
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draft.doctor,
                style: AppTypography.label.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: 4),
              Text(
                draft.doctorSpecialty.split(' · ').first,
                style: AppTypography.small.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _doctorImageFor(String doctor) => switch (doctor) {
  'Алексей Волков' => 'assets/images/booking/doctor_elena.png',
  'Елена Кузнецова' => 'assets/images/booking/doctor_alexey.png',
  'Любой специалист' => 'assets/images/booking/doctor_any.png',
  _ => 'assets/images/booking/doctor_anna.png',
};

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.draft});
  final BookingDraft draft;
  @override
  Widget build(BuildContext context) => _InfoCard(
    items: [
      ('Ваш выбор', '${draft.day} ${_monthName(draft.month)} · ${draft.time}'),
    ],
  );
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({required this.draft});
  final BookingDraft draft;
  @override
  Widget build(BuildContext context) => _InfoCard(
    items: [
      (
        'Дата и время',
        '${draft.day} ${_monthName(draft.month)} · ${draft.time}',
      ),
      ('Клиника', 'пр. Просвещения, 15'),
      ('Услуга и врач', '${draft.service}\n${draft.doctor}'),
      ('Пациент', draft.patientName),
    ],
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});
  final List<(String, String)> items;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items
              .expand(
                (item) => [
                  Text(
                    item.$1,
                    style: AppTypography.small.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(item.$2, style: AppTypography.body),
                  const SizedBox(height: 12),
                ],
              )
              .toList()
            ..removeLast(),
    ),
  );
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();
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
        SvgPicture.asset(
          'assets/icons/actions/booking_bell.svg',
          width: 24,
          height: 24,
        ),
        const SizedBox(height: 12),
        Text(
          'Напомним о приёме',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 12),
        Text(
          'За день и за 2 часа — если вы разрешите уведомления.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _BookingFooter extends StatelessWidget {
  const _BookingFooter({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  @override
  Widget build(BuildContext context) => Container(
    height: 88,
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
    color: AppColors.surface,
    child: AppButton(
      label: label,
      isLoading: isLoading,
      onPressed: isLoading ? null : onPressed,
    ),
  );
}

List<Widget> _withSpacing(List<Widget> children, double spacing) {
  return [
    for (var index = 0; index < children.length; index++) ...[
      children[index],
      if (index != children.length - 1) SizedBox(width: spacing),
    ],
  ];
}

bool _sameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String _monthName(int month, {bool capitalized = false}) {
  const names = [
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
  ];
  final name = names[month - 1];
  return capitalized ? '${name[0].toUpperCase()}${name.substring(1)}' : name;
}

String _weekdayName(int weekday) {
  const names = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];
  return names[weekday - 1];
}

const _bookingGradient = LinearGradient(
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

const _dateTimeTitleGradient = LinearGradient(
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
  stops: [0, .20383, .32272, .40765, .49258, .56052, .71339, .84928],
);

const _confirmationGradient = LinearGradient(
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
  stops: [0, .12174, .19275, .24348, .2942, .33478, .42609, .50725],
);

const _monthGradient = LinearGradient(
  colors: [
    AppColors.brand,
    AppColors.brand,
    AppColors.sky,
    Color(0xFFA46BD5),
    AppColors.coral,
    AppColors.accent,
    AppColors.accent,
  ],
  stops: [0, .17945, .26806, .3423, .40936, .48852, 1],
);

const _timeUnavailableGradient = LinearGradient(
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
  stops: [0, .23583, .37339, .47165, .56991, .64852, .82539, .98261],
);

const _offlineLastLineGradient = LinearGradient(
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
  stops: [0, .074435, .11786, .14887, .17988, .2047, .26052, .31014],
);

const _bookingSuccessGradient = LinearGradient(
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
  stops: [0, .13774, .21809, .27548, .33287, .37878, .48209, .57391],
);

const _reminderTitleGradient = LinearGradient(
  colors: [
    AppColors.brand,
    AppColors.brand,
    AppColors.sky,
    Color(0xFFA46BD5),
    AppColors.coral,
    AppColors.accent,
    AppColors.accent,
  ],
  stops: [0, .28588, .36517, .43785, .52375, .59643, 1],
);
