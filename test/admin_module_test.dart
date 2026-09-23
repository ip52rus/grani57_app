import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/app/startup/startup_destination.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/core/mock_runtime/admin_demo_store.dart';
import 'package:grani57_app/core/mock_runtime/demo_auth_service.dart';
import 'package:grani57_app/core/mock_runtime/demo_session.dart';
import 'package:grani57_app/core/mock_runtime/demo_session_store.dart';
import 'package:grani57_app/core/mock_runtime/doctor_access_store.dart';
import 'package:grani57_app/core/mock_runtime/user_role.dart';
import 'package:grani57_app/features/admin/admin_doctor_access_screen.dart';
import 'package:grani57_app/features/admin/admin_publications_screen.dart';
import 'package:grani57_app/features/admin/admin_shell_screen.dart';
import 'package:grani57_app/features/doctor_auth/doctor_login_screen.dart';
import 'package:grani57_app/features/doctor_schedule/doctor_schedule_screen.dart';
import 'package:grani57_app/features/patient_auth/patient_phone_login_screen.dart';
import 'package:grani57_app/mock_data/demo_admin_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('admin fixture authenticates as administrator', () async {
    final session = await DemoAuthService().authenticateEmployee(
      login: 'admin57',
      password: 'Grani57Demo!',
    );

    expect(session?.userId, 'admin_001');
    expect(session?.role, UserRole.administrator);
  });

  test('invalid admin credentials do not create a session', () async {
    expect(
      await DemoAuthService().authenticateEmployee(
        login: 'admin57',
        password: 'wrong',
      ),
      isNull,
    );
  });

  testWidgets('restored administrator session opens admin module', (
    tester,
  ) async {
    const session = DemoSession.authenticated(
      userId: 'admin_001',
      role: UserRole.administrator,
      name: 'Ирина',
    );
    await _pump(
      tester,
      widgetForStartupDestination(
        destinationForSession(session),
        session: session,
      ),
    );

    expect(find.byType(AdminShellScreen), findsOneWidget);
    expect(find.byType(DoctorScheduleScreen), findsNothing);
  });

  testWidgets('employee login routes administrator to admin shell', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final sessionStore = DemoSessionStore(preferences: preferences);
    final adminStore = AdminDemoStore(preferences: preferences);
    final accessStore = DoctorAccessStore(preferences: preferences);
    await _pump(
      tester,
      DoctorLoginScreen(
        sessionStore: sessionStore,
        authService: DemoAuthService(
          adminStore: adminStore,
          doctorAccessStore: accessStore,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'admin57');
    await tester.enterText(find.byType(TextField).last, 'Grani57Demo!');
    await tester.tap(find.byKey(const ValueKey('doctor.login.submit')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminShellScreen), findsOneWidget);
    expect(find.text('Управление'), findsOneWidget);
    expect((await sessionStore.restoreSession()).role, UserRole.administrator);
  });

  test('publication and doctor CRUD persist through a new store', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = AdminDemoStore(preferences: preferences);
    await store.initialize();

    const publication = DemoPublication(
      id: 'publication_test',
      type: DemoPublicationType.news,
      title: 'Тестовая новость',
      description: 'Описание',
      information: 'Информация',
      clinic: 'Все клиники',
      period: 'Сегодня',
      isPublished: false,
    );
    const doctor = DemoDoctorProfile(
      id: 'doctor_test',
      name: 'Тестовый Врач',
      description: 'Стоматолог',
      services: ['Консультация стоматолога'],
    );
    await store.savePublication(publication);
    await store.saveDoctor(doctor);

    final restored = AdminDemoStore(preferences: preferences);
    await restored.initialize();
    expect(
      restored.publications.any((item) => item.id == publication.id),
      true,
    );
    expect(restored.doctorById(doctor.id)?.name, doctor.name);

    await restored.deletePublication(publication.id);
    await restored.deleteDoctor(doctor.id);
    expect(
      restored.publications.any((item) => item.id == publication.id),
      false,
    );
    expect(restored.doctorById(doctor.id), isNull);
  });

  test(
    'doctor access is linked by doctorId and controls authentication',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final adminStore = AdminDemoStore(preferences: preferences);
      final accessStore = DoctorAccessStore(preferences: preferences);
      await adminStore.initialize();
      await accessStore.initialize();
      const doctor = DemoDoctorProfile(
        id: 'doctor_linked',
        name: 'Ольга Новая',
        description: 'Стоматолог-терапевт',
        services: ['Лечение зубов'],
      );
      await adminStore.saveDoctor(doctor);
      await accessStore.save(
        const DemoDoctorAccess(
          doctorId: 'doctor_linked',
          login: 'olga.new',
          password: 'Secure57!',
          isEnabled: true,
        ),
      );
      final auth = DemoAuthService(
        adminStore: adminStore,
        doctorAccessStore: accessStore,
      );

      final session = await auth.authenticateEmployee(
        login: 'olga.new',
        password: 'Secure57!',
      );
      expect(session?.userId, doctor.id);
      expect(session?.name, doctor.name);

      await accessStore.setEnabled(doctor.id, false);
      expect(
        await auth.authenticateEmployee(
          login: 'olga.new',
          password: 'Secure57!',
        ),
        isNull,
      );
      await accessStore.setEnabled(doctor.id, true);
      await accessStore.save(
        const DemoDoctorAccess(
          doctorId: 'doctor_linked',
          login: 'olga.updated',
          password: 'Updated57!',
          isEnabled: true,
        ),
      );
      expect(
        (await auth.authenticateEmployee(
          login: 'olga.updated',
          password: 'Updated57!',
        ))?.userId,
        doctor.id,
      );

      await accessStore.remove(doctor.id);
      expect(
        await auth.authenticateEmployee(
          login: 'olga.updated',
          password: 'Updated57!',
        ),
        isNull,
      );
    },
  );

  testWidgets('admin-created doctor credentials open the linked cabinet', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final adminStore = AdminDemoStore(preferences: preferences);
    final accessStore = DoctorAccessStore(preferences: preferences);
    await adminStore.initialize();
    await accessStore.initialize();
    await accessStore.save(
      const DemoDoctorAccess(
        doctorId: 'doctor_002',
        login: 'alex.volkov',
        password: 'Volkov57!',
        isEnabled: true,
      ),
    );
    await _pump(
      tester,
      DoctorLoginScreen(
        sessionStore: DemoSessionStore(preferences: preferences),
        authService: DemoAuthService(
          adminStore: adminStore,
          doctorAccessStore: accessStore,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'alex.volkov');
    await tester.enterText(find.byType(TextField).last, 'Volkov57!');
    await tester.tap(find.byKey(const ValueKey('doctor.login.submit')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminShellScreen), findsNothing);
    expect(find.byType(DoctorScheduleScreen), findsOneWidget);
    expect(find.text('Алексей Волков'), findsOneWidget);
    expect(find.text('На этот день'), findsOneWidget);
  });

  testWidgets('admin home and bottom navigation open both modules', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await _pump(
      tester,
      AdminShellScreen(
        store: AdminDemoStore(preferences: preferences),
        accessStore: DoctorAccessStore(preferences: preferences),
        sessionStore: DemoSessionStore(preferences: preferences),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('admin.home.publications')));
    await tester.pumpAndSettle();
    expect(find.text('Публикации'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('admin.nav.doctors')));
    await tester.pumpAndSettle();
    expect(find.text('Врачи и услуги'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('admin.nav.home')));
    await tester.pumpAndSettle();
    expect(find.text('Управление'), findsOneWidget);
  });

  testWidgets('publication form creates a persisted draft', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final store = AdminDemoStore(preferences: preferences);
    await store.initialize();
    await _pump(tester, AdminPublicationFormScreen(store: store));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Новая публикация');
    await tester.enterText(fields.at(1), 'Описание публикации');
    await tester.tap(find.byKey(const ValueKey('admin.publication.save')));
    await tester.pumpAndSettle();

    expect(
      store.publications.any((item) => item.title == 'Новая публикация'),
      true,
    );
  });

  testWidgets('access screen updates the seeded doctor credentials', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final adminStore = AdminDemoStore(preferences: preferences);
    final accessStore = DoctorAccessStore(preferences: preferences);
    await adminStore.initialize();
    await accessStore.initialize();
    final doctor = adminStore.doctorById('doctor_001')!;
    await _pump(
      tester,
      AdminDoctorAccessScreen(doctor: doctor, accessStore: accessStore),
    );

    await tester.enterText(find.byType(TextField).at(0), 'doctor.smirnova');
    await tester.enterText(find.byType(TextField).at(1), 'Smirnova57!');
    await tester.tap(find.byKey(const ValueKey('admin.doctorAccess.save')));
    await tester.pumpAndSettle();

    final access = accessStore.accessForDoctor(doctor.id);
    expect(access?.login, 'doctor.smirnova');
    expect(access?.password, 'Smirnova57!');
  });

  testWidgets('linked doctor opens a schedule filtered by doctorId', (
    tester,
  ) async {
    await _pump(
      tester,
      const DoctorScheduleScreen(
        doctorId: 'doctor_002',
        doctorName: 'Алексей Волков',
      ),
    );

    expect(find.text('Алексей Волков'), findsOneWidget);
    expect(find.text('На этот день'), findsOneWidget);
    expect(find.text('Дмитрий Соколов'), findsNothing);
  });

  testWidgets('admin logout clears session', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final sessionStore = DemoSessionStore(preferences: preferences);
    await sessionStore.saveSession(
      const DemoSession.authenticated(
        userId: 'admin_001',
        role: UserRole.administrator,
        name: 'Ирина',
      ),
    );
    await _pump(
      tester,
      AdminShellScreen(
        store: AdminDemoStore(preferences: preferences),
        accessStore: DoctorAccessStore(preferences: preferences),
        sessionStore: sessionStore,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('admin.signOut')));
    await tester.pumpAndSettle();

    expect(find.byType(PatientPhoneLoginScreen), findsOneWidget);
    expect((await sessionStore.restoreSession()).isAuthenticated, isFalse);
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
