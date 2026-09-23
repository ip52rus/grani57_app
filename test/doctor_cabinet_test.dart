import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/app/startup/startup_destination.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/core/mock_runtime/demo_auth_service.dart';
import 'package:grani57_app/core/mock_runtime/demo_session.dart';
import 'package:grani57_app/core/mock_runtime/demo_session_store.dart';
import 'package:grani57_app/core/mock_runtime/user_role.dart';
import 'package:grani57_app/features/doctor_auth/doctor_login_screen.dart';
import 'package:grani57_app/features/doctor_schedule/doctor_appointment_detail_screen.dart';
import 'package:grani57_app/features/doctor_schedule/doctor_schedule_screen.dart';
import 'package:grani57_app/features/patient_auth/patient_phone_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('valid doctor credentials create a doctor session', () async {
    final session = await DemoAuthService().authenticateEmployee(
      login: '+7 999 000-10-01',
      password: 'Doctor57!',
    );

    expect(session?.userId, 'doctor_001');
    expect(session?.role, UserRole.doctor);
  });

  test(
    'invalid and administrator credentials do not create doctor session',
    () async {
      final auth = DemoAuthService();

      expect(
        await auth.authenticateEmployee(
          login: '+7 999 000-10-01',
          password: 'wrong',
        ),
        isNull,
      );
      expect(
        (await auth.authenticateEmployee(
          login: 'admin57',
          password: 'Grani57Demo!',
        ))?.role,
        UserRole.administrator,
      );
    },
  );

  testWidgets('doctor login saves session and opens schedule', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final store = DemoSessionStore(preferences: preferences);
    await _pump(tester, DoctorLoginScreen(sessionStore: store));

    await tester.tap(find.byKey(const ValueKey('doctor.login.submit')));
    await tester.pumpAndSettle();

    expect(find.byType(DoctorScheduleScreen), findsOneWidget);
    final restored = await store.restoreSession();
    expect(restored.role, UserRole.doctor);
    expect(restored.userId, 'doctor_001');
  });

  testWidgets('invalid doctor login stays on login and shows validation', (
    tester,
  ) async {
    await _pump(tester, const DoctorLoginScreen());
    await tester.enterText(find.byType(TextField).last, 'wrong');

    await tester.tap(find.byKey(const ValueKey('doctor.login.submit')));
    await tester.pumpAndSettle();

    expect(find.byType(DoctorLoginScreen), findsOneWidget);
    expect(find.text('Неверный логин или пароль'), findsOneWidget);
  });

  testWidgets('restored doctor session routes to doctor schedule', (
    tester,
  ) async {
    const session = DemoSession.authenticated(
      userId: 'doctor_001',
      role: UserRole.doctor,
      name: 'Анна Смирнова',
    );

    await _pump(
      tester,
      widgetForStartupDestination(
        destinationForSession(session),
        session: session,
      ),
    );

    expect(find.byType(DoctorScheduleScreen), findsOneWidget);
    expect(find.text('Анна Смирнова'), findsOneWidget);
  });

  testWidgets('selecting appointment opens detail and back preserves date', (
    tester,
  ) async {
    await _pump(tester, const DoctorScheduleScreen());
    expect(find.text('Завершён'), findsOneWidget);
    expect(find.text('Подтверждён'), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey('doctor.appointment.status.appointment_002')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('doctor.appointment.appointment_002')),
      300,
    );
    await tester.tap(
      find.byKey(const ValueKey('doctor.appointment.appointment_002')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DoctorAppointmentDetailScreen), findsOneWidget);
    expect(find.text('Мария Петрова'), findsOneWidget);
    expect(find.text('Подтверждён'), findsNothing);
    expect(find.text('Завершён'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('doctor.appointment.backToSchedule')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DoctorScheduleScreen), findsOneWidget);
    expect(find.text('14 сентября, пн'), findsOneWidget);
  });

  testWidgets('empty date stays in schedule and replaces appointment cards', (
    tester,
  ) async {
    await _pump(tester, const DoctorScheduleScreen());

    await tester.tap(find.byKey(const ValueKey('doctor.calendar.day.15')));
    await tester.pumpAndSettle();

    expect(find.byType(DoctorScheduleScreen), findsOneWidget);
    expect(find.text('15 сентября, вт'), findsOneWidget);
    expect(find.text('На этот день'), findsOneWidget);
    expect(find.text('записей нет'), findsOneWidget);
    expect(find.text('К 14 сентября'), findsNothing);
    expect(
      find.byKey(const ValueKey('doctor.appointment.appointment_001')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('doctor.schedule.openEmptyDay')),
      findsNothing,
    );
  });

  testWidgets('doctor can sign out and the session is cleared', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final store = DemoSessionStore(preferences: preferences);
    await store.saveSession(
      const DemoSession.authenticated(
        userId: 'doctor_001',
        role: UserRole.doctor,
        name: 'Анна Смирнова',
      ),
    );
    await _pump(tester, DoctorScheduleScreen(sessionStore: store));

    await tester.tap(find.byKey(const ValueKey('doctor.schedule.signOut')));
    await tester.pumpAndSettle();

    expect(find.byType(PatientPhoneLoginScreen), findsOneWidget);
    expect((await store.restoreSession()).isAuthenticated, isFalse);
  });

  testWidgets('month controls and refresh preserve a valid selected date', (
    tester,
  ) async {
    var refreshes = 0;
    await _pump(tester, DoctorScheduleScreen(onRefresh: () => refreshes++));

    await tester.tap(find.byKey(const ValueKey('doctor.calendar.nextMonth')));
    await tester.pump();
    expect(find.text('Октябрь 2026'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('doctor.calendar.previousMonth')),
    );
    await tester.pump();
    expect(find.text('Сентябрь 2026'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('doctor.schedule.refresh')));
    await tester.pump();
    expect(refreshes, 1);
    expect(find.text('1 сентября, вт'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: child));
  await tester.pumpAndSettle();
}
