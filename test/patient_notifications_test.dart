import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/features/patient_booking/patient_booking_screens.dart';
import 'package:grani57_app/features/patient_home/patient_home_screen.dart';
import 'package:grani57_app/features/patient_notifications/patient_notification_permission.dart';
import 'package:grani57_app/features/patient_notifications/patient_notification_screens.dart';
import 'package:grani57_app/features/patient_notifications/patient_notification_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows populated and empty notification inbox states', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PatientNotificationsScreen(
          patientId: 'patient_001',
          patientName: 'Иван Петров',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Вы записаны на приём'), findsOneWidget);
    expect(find.text('Ваш документ готов'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: PatientNotificationsScreen(
          patientId: 'patient_003',
          patientName: 'Алексей Орлов',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Пока нет\nуведомлений'), findsOneWidget);
  });

  testWidgets('persists category switches independently', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final store = PatientNotificationStore(preferences);
    final permission = _FakePermissionGateway(
      PatientNotificationPermissionStatus.enabled,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PatientNotificationSettingsScreen(
          patientId: 'patient_001',
          patientName: 'Иван Петров',
          store: store,
          permissionGateway: permission,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(3));
    expect(tester.widget<Switch>(switches.at(0)).value, isTrue);
    expect(tester.widget<Switch>(switches.at(1)).value, isTrue);
    expect(tester.widget<Switch>(switches.at(2)).value, isFalse);

    await tester.tap(switches.at(2));
    await tester.pumpAndSettle();

    expect((await store.loadPreferences('patient_001')).news, isTrue);
  });

  testWidgets('permission education requests OS permission once', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final store = PatientNotificationStore(preferences);
    final permission = _FakePermissionGateway(
      PatientNotificationPermissionStatus.disabled,
      requestResult: PatientNotificationPermissionStatus.enabled,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PatientNotificationPermissionScreen(
          patientId: 'patient_001',
          patientName: 'Иван Петров',
          store: store,
          permissionGateway: permission,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Разрешить уведомления'));
    await tester.tap(find.text('Разрешить уведомления'));
    await tester.pumpAndSettle();

    expect(permission.requestCount, 1);
    expect(await store.wasPermissionRequested('patient_001'), isTrue);
    expect(find.text('Что Вам напоминать?'), findsOneWidget);
    expect(find.text('Уведомления разрешены'), findsOneWidget);
  });

  testWidgets('denied permission opens system app settings', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final store = PatientNotificationStore(preferences);
    await store.markPermissionRequested('patient_001');
    final permission = _FakePermissionGateway(
      PatientNotificationPermissionStatus.disabled,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PatientNotificationSettingsScreen(
          patientId: 'patient_001',
          patientName: 'Иван Петров',
          store: store,
          permissionGateway: permission,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Уведомления запрещены'), findsOneWidget);
    await tester.tap(find.text('Открыть настройки телефона'));
    await tester.pump();
    expect(permission.openSettingsCount, 1);
  });

  testWidgets('home bell opens the patient notification inbox', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PatientHomeScreen(
          patientId: 'patient_001',
          patientFullName: 'Иван Петров',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Открыть уведомления'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientNotificationsScreen), findsOneWidget);
    expect(find.text('Вы записаны на приём'), findsOneWidget);
  });

  testWidgets('booking success opens the contextual permission education', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final store = PatientNotificationStore(preferences);
    final permission = _FakePermissionGateway(
      PatientNotificationPermissionStatus.disabled,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PatientBookingSuccessScreen(
          draft: const BookingDraft(
            patientId: 'patient_001',
            patientName: 'Иван Петров',
          ),
          notificationStore: store,
          notificationPermissionGateway: permission,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Включить напоминания'));
    await tester.tap(find.text('Включить напоминания'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientNotificationPermissionScreen), findsOneWidget);
    expect(find.text('Напомним о важном'), findsOneWidget);
  });
}

class _FakePermissionGateway implements PatientNotificationPermissionGateway {
  _FakePermissionGateway(this.current, {this.requestResult});

  PatientNotificationPermissionStatus current;
  final PatientNotificationPermissionStatus? requestResult;
  int requestCount = 0;
  int openSettingsCount = 0;

  @override
  Future<PatientNotificationPermissionStatus> status() async => current;

  @override
  Future<PatientNotificationPermissionStatus> request() async {
    requestCount += 1;
    current = requestResult ?? current;
    return current;
  }

  @override
  Future<bool> openSystemSettings() async {
    openSettingsCount += 1;
    return true;
  }
}
