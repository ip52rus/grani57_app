import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/features/patient_notifications/patient_notification_permission.dart';
import 'package:grani57_app/features/patient_notifications/patient_notification_screens.dart';
import 'package:grani57_app/features/patient_notifications/patient_notification_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await _loadManropeFonts();
    for (final name in [
      'notifications',
      'notifications_empty',
      'notification_permission',
      'notification_settings',
      'notification_settings_denied',
    ]) {
      _copyReference(
        source: 'docs/figma_reference/patient_notifications/$name.png',
        target: 'docs/visual_tests/patient_notifications/${name}_figma.png',
      );
    }
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders populated notification inbox', (tester) async {
    await _renderScreen(
      tester,
      filePath:
          'docs/visual_tests/patient_notifications/notifications_flutter.png',
      child: const PatientNotificationsScreen(
        patientId: 'patient_001',
        patientName: 'Иван Петров',
      ),
    );
  });

  testWidgets('renders empty notification inbox', (tester) async {
    await _renderScreen(
      tester,
      filePath:
          'docs/visual_tests/patient_notifications/notifications_empty_flutter.png',
      child: const PatientNotificationsScreen(
        patientId: 'patient_003',
        patientName: 'Алексей Орлов',
      ),
    );
  });

  testWidgets('renders notification permission education', (tester) async {
    await _renderScreen(
      tester,
      filePath:
          'docs/visual_tests/patient_notifications/notification_permission_flutter.png',
      child: PatientNotificationPermissionScreen(
        patientId: 'patient_001',
        patientName: 'Иван Петров',
        permissionGateway: _FakePermissionGateway(
          PatientNotificationPermissionStatus.disabled,
        ),
      ),
    );
  });

  testWidgets('renders enabled notification settings', (tester) async {
    await _renderScreen(
      tester,
      filePath:
          'docs/visual_tests/patient_notifications/notification_settings_flutter.png',
      child: PatientNotificationSettingsScreen(
        patientId: 'patient_001',
        patientName: 'Иван Петров',
        permissionGateway: _FakePermissionGateway(
          PatientNotificationPermissionStatus.enabled,
        ),
      ),
    );
  });

  testWidgets('renders denied notification settings', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final store = PatientNotificationStore(preferences);
    await store.markPermissionRequested('patient_001');
    await _renderScreen(
      tester,
      filePath:
          'docs/visual_tests/patient_notifications/notification_settings_denied_flutter.png',
      child: PatientNotificationSettingsScreen(
        patientId: 'patient_001',
        patientName: 'Иван Петров',
        store: store,
        permissionGateway: _FakePermissionGateway(
          PatientNotificationPermissionStatus.disabled,
        ),
      ),
    );
  });
}

class _FakePermissionGateway implements PatientNotificationPermissionGateway {
  const _FakePermissionGateway(this.value);

  final PatientNotificationPermissionStatus value;

  @override
  Future<bool> openSystemSettings() async => true;

  @override
  Future<PatientNotificationPermissionStatus> request() async => value;

  @override
  Future<PatientNotificationPermissionStatus> status() async => value;
}

Future<void> _loadManropeFonts() async {
  final regular = rootBundle.load('assets/fonts/Manrope-Regular.ttf');
  final medium = rootBundle.load('assets/fonts/Manrope-Medium.ttf');
  final semiBold = rootBundle.load('assets/fonts/Manrope-SemiBold.ttf');
  await (FontLoader('Manrope')
        ..addFont(regular)
        ..addFont(medium)
        ..addFont(semiBold))
      .load();
}

void _copyReference({required String source, required String target}) {
  final targetFile = File(target);
  targetFile.parent.createSync(recursive: true);
  targetFile.writeAsBytesSync(File(source).readAsBytesSync());
}

Future<void> _renderScreen(
  WidgetTester tester, {
  required Widget child,
  required String filePath,
}) async {
  final repaintKey = GlobalKey();
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(393, 852);

  await tester.pumpWidget(
    RepaintBoundary(
      key: repaintKey,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(393, 852),
                textScaler: TextScaler.noScaling,
              ).copyWith(padding: const EdgeInsets.only(top: 44)),
              child: child,
            ),
          ),
          const _FigmaStatusBar(),
        ],
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();

  await expectLater(
    find.byKey(repaintKey),
    matchesGoldenFile(Uri.file(File(filePath).absolute.path)),
  );
}

class _FigmaStatusBar extends StatelessWidget {
  const _FigmaStatusBar();

  @override
  Widget build(BuildContext context) => const Positioned(
    left: 0,
    top: 0,
    width: 393,
    height: 44,
    child: IgnorePointer(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned(
              left: 24,
              top: 12,
              child: Text(
                '9:41',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  height: 20 / 14,
                  color: Color(0xFF576A86),
                ),
              ),
            ),
            Positioned(
              left: 302,
              top: 17,
              child: SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF172B4D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 319,
              top: 20,
              child: SizedBox(
                width: 12,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF172B4D),
                    borderRadius: BorderRadius.all(Radius.circular(1)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
