import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/navigation/app_page_route.dart';
import '../../mock_data/demo_patient_appointments.dart';
import '../../mock_data/demo_patient_documents.dart';
import '../patient_appointments/patient_appointment_details_screen.dart';
import '../patient_documents/patient_conclusion_screen.dart';
import '../patient_home/patient_news_screen.dart';
import 'demo_patient_notifications.dart';
import 'patient_notification_permission.dart';
import 'patient_notification_store.dart';

class PatientNotificationsScreen extends StatefulWidget {
  const PatientNotificationsScreen({
    this.patientId,
    required this.patientName,
    this.store,
    super.key,
  });

  final String? patientId;
  final String patientName;
  final PatientNotificationStore? store;

  @override
  State<PatientNotificationsScreen> createState() =>
      _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState
    extends State<PatientNotificationsScreen> {
  late final PatientNotificationStore _store =
      widget.store ?? PatientNotificationStore();
  Set<String> _readIds = const {};

  String get _patientId => widget.patientId ?? 'demo_patient';

  @override
  void initState() {
    super.initState();
    _loadReadIds();
  }

  Future<void> _loadReadIds() async {
    final value = await _store.readIds(_patientId);
    if (mounted) setState(() => _readIds = value);
  }

  void _openSettings() {
    Navigator.of(context).push(
      appPageRoute<void>(
        context,
        builder: (_) => PatientNotificationSettingsScreen(
          patientId: _patientId,
          patientName: widget.patientName,
          store: _store,
        ),
      ),
    );
  }

  Future<void> _openNotification(DemoPatientNotification notification) async {
    await _store.markRead(_patientId, notification.id);
    if (!mounted) return;
    setState(() => _readIds = {..._readIds, notification.id});

    final Widget destination = switch (notification.kind) {
      PatientNotificationKind.appointment => PatientAppointmentDetailsScreen(
        appointment:
            DemoPatientAppointments.upcomingFor(widget.patientId).firstOrNull ??
            DemoPatientAppointment(
              startsAt: DateTime(2026, 9, 14, 10, 30),
              service: 'Консультация стоматолога',
              doctor: 'Анна Смирнова',
              clinic: 'пр. Просвещения, 15',
            ),
      ),
      PatientNotificationKind.document => PatientConclusionScreen(
        document: DemoPatientDocuments.items.first,
        patientName: widget.patientName,
      ),
      PatientNotificationKind.news => PatientNewsScreen(
        article: PatientNewsArticle.newBranch,
        patientId: widget.patientId,
        patientName: widget.patientName,
      ),
    };
    await Navigator.of(
      context,
    ).push(appPageRoute<void>(context, builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    final notifications = DemoPatientNotifications.forPatient(widget.patientId);
    return _NotificationScaffold(
      title: 'Уведомления',
      child: notifications.isEmpty
          ? _EmptyNotifications(onOpenSettings: _openSettings)
          : _NotificationList(
              notifications: notifications,
              readIds: _readIds,
              onOpenSettings: _openSettings,
              onOpenNotification: _openNotification,
            ),
    );
  }
}

class PatientNotificationPermissionScreen extends StatefulWidget {
  const PatientNotificationPermissionScreen({
    required this.patientId,
    required this.patientName,
    this.store,
    this.permissionGateway,
    this.onNotNow,
    this.returnToPreviousSettings = false,
    super.key,
  });

  final String patientId;
  final String patientName;
  final PatientNotificationStore? store;
  final PatientNotificationPermissionGateway? permissionGateway;
  final VoidCallback? onNotNow;
  final bool returnToPreviousSettings;

  @override
  State<PatientNotificationPermissionScreen> createState() =>
      _PatientNotificationPermissionScreenState();
}

class _PatientNotificationPermissionScreenState
    extends State<PatientNotificationPermissionScreen> {
  late final PatientNotificationStore _store =
      widget.store ?? PatientNotificationStore();
  late final PatientNotificationPermissionGateway _permissionGateway =
      widget.permissionGateway ??
      const DevicePatientNotificationPermissionGateway();
  var _isRequesting = false;

  Future<void> _requestPermission() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);
    await _store.markPermissionRequested(widget.patientId);
    await _permissionGateway.request();
    if (!mounted) return;
    if (widget.returnToPreviousSettings) {
      Navigator.of(context).pop(true);
      return;
    }
    Navigator.of(context).pushReplacement(
      appPageRoute<void>(
        context,
        builder: (_) => PatientNotificationSettingsScreen(
          patientId: widget.patientId,
          patientName: widget.patientName,
          store: _store,
          permissionGateway: _permissionGateway,
        ),
      ),
    );
  }

  void _notNow() {
    if (widget.onNotNow case final callback?) {
      callback();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) => _NotificationScaffold(
    title: 'Напоминания',
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              'assets/icons/status/notification_permission.svg',
              width: 56,
              height: 56,
            ),
          ),
          const SizedBox(height: 20),
          const _GradientHeading(
            text: 'Напомним о важном',
            shaderWidthFactor: 1.1022363901138306,
          ),
          const SizedBox(height: 20),
          Text(
            'О приёмах и готовности документов.',
            style: AppTypography.small.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 20),
          const _PushPreviewCard(),
          const SizedBox(height: 20),
          SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'На следующем шаге телефон попросит разрешение на уведомления. '
                'Новости и акции включаются отдельно.',
                style: AppTypography.small.copyWith(color: AppColors.secondary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Разрешить уведомления',
            isLoading: _isRequesting,
            onPressed: _requestPermission,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Не сейчас',
            variant: AppButtonVariant.ghost,
            onPressed: _notNow,
          ),
        ],
      ),
    ),
  );
}

class PatientNotificationSettingsScreen extends StatefulWidget {
  const PatientNotificationSettingsScreen({
    required this.patientId,
    required this.patientName,
    this.store,
    this.permissionGateway,
    super.key,
  });

  final String patientId;
  final String patientName;
  final PatientNotificationStore? store;
  final PatientNotificationPermissionGateway? permissionGateway;

  @override
  State<PatientNotificationSettingsScreen> createState() =>
      _PatientNotificationSettingsScreenState();
}

class _PatientNotificationSettingsScreenState
    extends State<PatientNotificationSettingsScreen>
    with WidgetsBindingObserver {
  late final PatientNotificationStore _store =
      widget.store ?? PatientNotificationStore();
  late final PatientNotificationPermissionGateway _permissionGateway =
      widget.permissionGateway ??
      const DevicePatientNotificationPermissionGateway();

  var _preferences = const PatientNotificationPreferences();
  var _permission = PatientNotificationPermissionStatus.disabled;
  var _wasRequested = false;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final values = await Future.wait<Object>([
      _store.loadPreferences(widget.patientId),
      _permissionGateway.status(),
      _store.wasPermissionRequested(widget.patientId),
    ]);
    if (!mounted) return;
    setState(() {
      _preferences = values[0] as PatientNotificationPreferences;
      _permission = values[1] as PatientNotificationPermissionStatus;
      _wasRequested = values[2] as bool;
      _isLoading = false;
    });
  }

  Future<void> _update(PatientNotificationPreferences value) async {
    setState(() => _preferences = value);
    await _store.savePreferences(widget.patientId, value);
  }

  Future<void> _openPermissionEducation() async {
    final requested = await Navigator.of(context).push<bool>(
      appPageRoute<bool>(
        context,
        builder: (_) => PatientNotificationPermissionScreen(
          patientId: widget.patientId,
          patientName: widget.patientName,
          store: _store,
          permissionGateway: _permissionGateway,
          returnToPreviousSettings: true,
        ),
      ),
    );
    if (requested == true) await _load();
  }

  Future<void> _openSystemSettings() async {
    await _permissionGateway.openSystemSettings();
  }

  @override
  Widget build(BuildContext context) => _NotificationScaffold(
    title: 'Уведомления',
    child: _isLoading
        ? const Center(child: CircularProgressIndicator.adaptive())
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _GradientHeading(
                  text: 'Что Вам напоминать?',
                  shaderWidthFactor: 1.0391566753387451,
                ),
                const SizedBox(height: 20),
                _PermissionStatusCard(
                  permission: _permission,
                  wasRequested: _wasRequested,
                  onAllow: _openPermissionEducation,
                  onOpenSettings: _openSystemSettings,
                ),
                const SizedBox(height: 20),
                _NotificationToggleCard(
                  title: 'О приёмах',
                  subtitle: 'Запись, перенос, отмена\nи напоминания',
                  value: _preferences.appointments,
                  onChanged: (value) =>
                      _update(_preferences.copyWith(appointments: value)),
                ),
                const SizedBox(height: 20),
                _NotificationToggleCard(
                  title: 'О документах',
                  subtitle: 'Когда готово новое заключение',
                  value: _preferences.documents,
                  onChanged: (value) =>
                      _update(_preferences.copyWith(documents: value)),
                ),
                const SizedBox(height: 20),
                _NotificationToggleCard(
                  title: 'Новости и акции',
                  subtitle: 'Предложения и события клиники',
                  value: _preferences.news,
                  onChanged: (value) =>
                      _update(_preferences.copyWith(news: value)),
                ),
                const SizedBox(height: 20),
                Text(
                  'В push-сообщениях нет диагнозов и результатов лечения. '
                  'Подробности доступны только после входа.',
                  style: AppTypography.small.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
  );
}

class _NotificationScaffold extends StatelessWidget {
  const _NotificationScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

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
            _NotificationHeader(title: title),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  'assets/icons/actions/back.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.label.copyWith(color: AppColors.brand),
          ),
        ],
      ),
    ),
  );
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.notifications,
    required this.readIds,
    required this.onOpenSettings,
    required this.onOpenNotification,
  });

  final List<DemoPatientNotification> notifications;
  final Set<String> readIds;
  final VoidCallback onOpenSettings;
  final ValueChanged<DemoPatientNotification> onOpenNotification;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
    children: [
      const _GradientHeading(
        text: 'Важное для Вас',
        shaderWidthFactor: 1.431535243988037,
      ),
      const SizedBox(height: 20),
      _OpenNotificationSettingsCard(onTap: onOpenSettings),
      const SizedBox(height: 20),
      Text(
        'Сегодня',
        style: AppTypography.small.copyWith(color: AppColors.secondary),
      ),
      const SizedBox(height: 20),
      for (var index = 0; index < notifications.length; index++) ...[
        _NotificationEventCard(
          notification: notifications[index],
          isRead: readIds.contains(notifications[index].id),
          onTap: () => onOpenNotification(notifications[index]),
        ),
        if (index != notifications.length - 1) const SizedBox(height: 20),
      ],
    ],
  );
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GradientHeading(
          text: 'Пока нет\nуведомлений',
          shaderWidthFactor: 1,
        ),
        const SizedBox(height: 20),
        Text(
          'Здесь появятся напоминания о Ваших записях и важные сообщения '
          'клиники.',
          style: AppTypography.small.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Настроить уведомления',
          variant: AppButtonVariant.secondary,
          onPressed: onOpenSettings,
        ),
      ],
    ),
  );
}

class _GradientHeading extends StatelessWidget {
  const _GradientHeading({required this.text, required this.shaderWidthFactor});

  final String text;
  final double shaderWidthFactor;

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
      stops: const [0, 0.24, 0.38, 0.48, 0.58, 0.66, 0.84, 1],
    ).createShader(Rect.fromLTWH(0, 0, 345 / shaderWidthFactor, bounds.height)),
    child: Text(text, style: AppTypography.title),
  );
}

class _OpenNotificationSettingsCard extends StatelessWidget {
  const _OpenNotificationSettingsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _TapSurface(
    onTap: onTap,
    child: Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.radius20,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/actions/settings.svg',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Настроить уведомления', style: AppTypography.label),
                Text(
                  'Приёмы, документы, новости',
                  style: AppTypography.caption.copyWith(
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

class _NotificationEventCard extends StatelessWidget {
  const _NotificationEventCard({
    required this.notification,
    required this.isRead,
    required this.onTap,
  });

  final DemoPatientNotification notification;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _TapSurface(
    onTap: onTap,
    child: Container(
      height: notification.isNew && !isRead ? 188 : 152,
      padding: notification.isNew && !isRead
          ? const EdgeInsets.all(24)
          : const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notification.isNew && !isRead
            ? AppColors.soft
            : AppColors.surface,
        borderRadius: AppRadii.radius20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.isNew && !isRead) ...[
            Text(
              'Новое',
              style: AppTypography.caption.copyWith(color: AppColors.brand),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            notification.title,
            style: AppTypography.label.copyWith(color: AppColors.brand),
          ),
          SizedBox(height: notification.isNew && !isRead ? 14 : 16),
          Text(notification.body, style: AppTypography.small),
          SizedBox(height: notification.isNew && !isRead ? 14 : 12),
          Text(
            notification.timestamp,
            style: AppTypography.caption.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    ),
  );
}

class _PushPreviewCard extends StatelessWidget {
  const _PushPreviewCard();

  @override
  Widget build(BuildContext context) => Container(
    height: 132,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.soft,
      borderRadius: AppRadii.radius20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '57 ГРАНЕЙ · сейчас',
          style: AppTypography.caption.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 16),
        Text(
          'У Вас запланирован приём',
          style: AppTypography.label.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: 16),
        const Text(
          'Подробности записи — в приложении.',
          style: AppTypography.small,
        ),
      ],
    ),
  );
}

class _PermissionStatusCard extends StatelessWidget {
  const _PermissionStatusCard({
    required this.permission,
    required this.wasRequested,
    required this.onAllow,
    required this.onOpenSettings,
  });

  final PatientNotificationPermissionStatus permission;
  final bool wasRequested;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final enabled = permission == PatientNotificationPermissionStatus.enabled;
    final title = enabled
        ? 'Уведомления разрешены'
        : wasRequested
        ? 'Уведомления запрещены'
        : 'Уведомления не разрешены';
    final body = enabled
        ? 'Если сообщения не приходят, проверьте разрешения в настройках телефона.'
        : wasRequested
        ? 'Разрешите уведомления в настройках телефона, чтобы получать напоминания.'
        : 'Разрешите уведомления, чтобы получать напоминания о приёмах и документах.';

    return SizedBox(
      height: enabled ? 116 : 204,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.soft,
          borderRadius: AppRadii.radius20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: AppTypography.small.copyWith(color: AppColors.secondary),
            ),
            if (!enabled) ...[
              const SizedBox(height: 32),
              AppButton(
                label: wasRequested
                    ? 'Открыть настройки телефона'
                    : 'Разрешить уведомления',
                onPressed: wasRequested ? onOpenSettings : onAllow,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationToggleCard extends StatelessWidget {
  const _NotificationToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: subtitle.contains('\n') ? 108 : 88,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.radius20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(color: AppColors.brand),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accent,
            activeThumbColor: AppColors.surface,
            inactiveTrackColor: AppColors.secondary,
            inactiveThumbColor: AppColors.surface,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    ),
  );
}

class _TapSurface extends StatelessWidget {
  const _TapSurface({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      borderRadius: AppRadii.radius20,
      child: child,
    ),
  );
}
