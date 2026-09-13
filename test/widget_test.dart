import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grani57_app/app/app.dart';
import 'package:grani57_app/app/startup/splash_screen.dart';
import 'package:grani57_app/core/mock_runtime/demo_auth_service.dart';
import 'package:grani57_app/core/mock_runtime/demo_session.dart';
import 'package:grani57_app/core/mock_runtime/demo_session_store.dart';
import 'package:grani57_app/core/mock_runtime/user_role.dart';
import 'package:grani57_app/core/design_system/components/app_button.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/core/design_system/tokens/app_colors.dart';
import 'package:grani57_app/core/design_system/tokens/app_spacing.dart';
import 'package:grani57_app/core/design_system/typography/app_typography.dart';
import 'package:grani57_app/features/patient_auth/patient_phone_login_screen.dart';
import 'package:grani57_app/features/patient_auth/russian_phone_input_formatter.dart';
import 'package:grani57_app/mock_data/demo_asset_paths.dart';
import 'package:grani57_app/mock_data/demo_patients.dart';
import 'package:grani57_app/mock_data/demo_schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('application bootstraps with splash without counter app', (
    tester,
  ) async {
    await tester.pumpWidget(
      Grani57App(
        restoreSession: () async => const DemoSession.unauthenticated(),
        minimumSplashDuration: Duration.zero,
        splashFadeDuration: Duration.zero,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Вход'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
  });

  test('light theme uses design system tokens', () {
    final theme = AppTheme.light;

    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.primary, AppColors.brand);
    expect(theme.textTheme.headlineLarge?.fontFamily, AppTypography.fontFamily);
    expect(AppSpacing.pagePadding, 24);
  });

  testWidgets('Splash renders real logo asset', (tester) async {
    final logoSvg = await rootBundle.loadString(DemoAssetPaths.logoWelcome);

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(logoSvg, contains('<svg width="260" height="75"'));
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('Splash starts transparent and transitions toward visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(fadeDuration: Duration(milliseconds: 1500)),
      ),
    );

    FadeTransition fadeTransition = tester.widget(
      find.byKey(const ValueKey('splash.logo.fade')),
    );
    expect(fadeTransition.opacity.value, 0);

    await tester.pump(const Duration(milliseconds: 500));
    fadeTransition = tester.widget(
      find.byKey(const ValueKey('splash.logo.fade')),
    );

    expect(fadeTransition.opacity.value, greaterThan(0));
    expect(fadeTransition.opacity.value, lessThan(1));
  });

  testWidgets('no session routes to patient login screen', (tester) async {
    await _pumpStartupWithSession(tester, const DemoSession.unauthenticated());

    expect(find.text('Вход'), findsOneWidget);
  });

  testWidgets('patient session routes to patient shell placeholder', (
    tester,
  ) async {
    await _pumpStartupWithSession(
      tester,
      const DemoSession.authenticated(
        userId: 'patient_001',
        role: UserRole.patient,
      ),
    );

    expect(find.text('Patient shell'), findsOneWidget);
  });

  testWidgets('doctor session routes to doctor shell placeholder', (
    tester,
  ) async {
    await _pumpStartupWithSession(
      tester,
      const DemoSession.authenticated(
        userId: 'doctor_001',
        role: UserRole.doctor,
      ),
    );

    expect(find.text('Doctor shell'), findsOneWidget);
  });

  testWidgets('admin session routes to administrator shell placeholder', (
    tester,
  ) async {
    await _pumpStartupWithSession(
      tester,
      const DemoSession.authenticated(
        userId: 'admin_001',
        role: UserRole.administrator,
      ),
    );

    expect(find.text('Administrator shell'), findsOneWidget);
  });

  testWidgets('invalid session routes to patient auth fallback', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'demo_session.is_authenticated': true,
      'demo_session.user_id': 'patient_001',
      'demo_session.role': 'unknown_role',
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      Grani57App(
        sessionStore: DemoSessionStore(preferences: preferences),
        minimumSplashDuration: Duration.zero,
        splashFadeDuration: Duration.zero,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Вход'), findsOneWidget);
    expect(preferences.getBool('demo_session.is_authenticated'), isNull);
    expect(preferences.getString('demo_session.user_id'), isNull);
    expect(preferences.getString('demo_session.role'), isNull);
  });

  testWidgets('Splash is removed from navigation stack after routing', (
    tester,
  ) async {
    await _pumpStartupWithSession(
      tester,
      const DemoSession.authenticated(
        userId: 'patient_001',
        role: UserRole.patient,
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('Patient shell'), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });

  test('Manrope typography maps required weights', () {
    expect(AppTypography.body.fontFamily, 'Manrope');
    expect(AppTypography.body.fontWeight, FontWeight.w400);
    expect(AppTypography.caption.fontWeight, FontWeight.w500);
    expect(AppTypography.heading.fontWeight, FontWeight.w600);
  });

  testWidgets('font manifest includes static Manrope files', (tester) async {
    final manifest = await rootBundle.loadString('FontManifest.json');

    expect(manifest, contains('Manrope-Regular.ttf'));
    expect(manifest, contains('Manrope-Medium.ttf'));
    expect(manifest, contains('Manrope-SemiBold.ttf'));
  });

  test('phone normalization handles supported Russian formats', () {
    expect(normalizeRussianPhone('+7 999 000-00-01'), '79990000001');
    expect(normalizeRussianPhone('+79990000001'), '79990000001');
    expect(normalizeRussianPhone('89990000001'), '79990000001');
  });

  test('phone formatter keeps convenient Russian display format', () {
    expect(formatRussianPhone('+79990000001'), '+7 999 000-00-01');
    expect(formatRussianPhone('89990000001'), '+7 999 000-00-01');
  });

  test('demo patient lookup finds all registered patients', () {
    final auth = DemoAuthService();

    for (final patient in DemoPatients.values) {
      final lookup = auth.lookupPatientByPhone(patient.phone);

      expect(lookup.isRegistered, isTrue);
      expect(lookup.patient?.id, patient.id);
    }
  });

  test('demo patient lookup treats unknown phone as new patient concept', () {
    final auth = DemoAuthService();

    final lookup = auth.lookupPatientByPhone('+7 999 000-99-99');

    expect(lookup.isRegistered, isFalse);
    expect(lookup.patient, isNull);
    expect(lookup.normalizedPhone, '79990009999');
  });

  testWidgets('Patient Login renders', (tester) async {
    await _pumpPatientLogin(tester);

    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Телефон'), findsOneWidget);
    expect(find.text('Получить код'), findsOneWidget);
    expect(find.text('Вход для сотрудников'), findsOneWidget);
  });

  testWidgets('Patient auth screens fit reference widths and use keyboards', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final width in <double>[360, 393, 430]) {
      tester.view.physicalSize = Size(width, 852);
      await _pumpPatientLogin(tester);

      final phoneField = tester.widget<TextField>(find.byType(TextField).first);
      expect(phoneField.keyboardType, TextInputType.phone);
      expect(tester.takeException(), isNull);

      await _submitPhone(tester, '+7 999 000-00-01');
      final codeField = tester.widget<TextField>(find.byType(TextField).last);
      expect(codeField.keyboardType, TextInputType.number);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('known patient opens SMS screen', (tester) async {
    await _openSmsForPhone(tester, '+7 999 000-00-01');

    expect(find.text('Код подтверждения'), findsOneWidget);
    expect(find.textContaining('+7 999 000-00-01'), findsOneWidget);
  });

  testWidgets('unknown phone shows temporary registration state', (
    tester,
  ) async {
    await _pumpPatientLogin(tester);
    await _submitPhone(tester, '+7 999 000-99-99');

    expect(
      find.text(
        'Регистрация нового пациента будет реализована следующим этапом',
      ),
      findsOneWidget,
    );
    expect(find.text('Код подтверждения'), findsNothing);
  });

  testWidgets('correct SMS patient_001 saves session and routes to shell', (
    tester,
  ) async {
    final preferences = await _loginWithSms(
      tester,
      phone: '+7 999 000-00-01',
      code: '111111',
    );

    expect(find.text('Patient shell'), findsOneWidget);
    expect(preferences.getBool('demo_session.is_authenticated'), isTrue);
    expect(preferences.getString('demo_session.user_id'), 'patient_001');
    expect(preferences.getString('demo_session.role'), UserRole.patient.name);
  });

  testWidgets('correct SMS patient_002 saves session and routes to shell', (
    tester,
  ) async {
    final preferences = await _loginWithSms(
      tester,
      phone: '+7 999 000-00-02',
      code: '222222',
    );

    expect(find.text('Patient shell'), findsOneWidget);
    expect(preferences.getString('demo_session.user_id'), 'patient_002');
  });

  testWidgets('correct SMS patient_003 saves session and routes to shell', (
    tester,
  ) async {
    final preferences = await _loginWithSms(
      tester,
      phone: '+7 999 000-00-03',
      code: '333333',
    );

    expect(find.text('Patient shell'), findsOneWidget);
    expect(preferences.getString('demo_session.user_id'), 'patient_003');
  });

  testWidgets('wrong SMS remains unauthenticated', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await _openSmsForPhone(
      tester,
      '+7 999 000-00-01',
      sessionStore: DemoSessionStore(preferences: preferences),
    );

    await _submitSms(tester, '000000');

    expect(find.text('Неверный код подтверждения'), findsOneWidget);
    expect(find.text('Код подтверждения'), findsOneWidget);
    expect(preferences.getBool('demo_session.is_authenticated'), isNull);
  });

  testWidgets('Back from SMS returns to Login', (tester) async {
    await _openSmsForPhone(tester, '+7 999 000-00-01');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Код подтверждения'), findsNothing);
  });

  testWidgets('Back after successful authentication does not return to auth', (
    tester,
  ) async {
    await _loginWithSms(tester, phone: '+7 999 000-00-01', code: '111111');

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(find.text('Patient shell'), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('employee link opens EmployeeAuthPlaceholder', (tester) async {
    await _pumpPatientLogin(tester);

    await tester.tap(find.text('Вход для сотрудников'));
    await tester.pumpAndSettle();

    expect(find.text('Employee authentication'), findsOneWidget);
    expect(find.text('Development placeholder'), findsOneWidget);
  });

  testWidgets('restored authenticated patient skips Login after Splash', (
    tester,
  ) async {
    await _pumpStartupWithSession(
      tester,
      const DemoSession.authenticated(
        userId: 'patient_001',
        role: UserRole.patient,
      ),
    );

    expect(find.text('Patient shell'), findsOneWidget);
    expect(find.text('Вход'), findsNothing);
  });

  test('SMS validation accepts registered demo code', () {
    final auth = DemoAuthService();

    expect(
      auth.validatePatientSms(rawPhone: '+7 999 000-00-02', smsCode: '222222'),
      isTrue,
    );
  });

  test('SMS validation rejects incorrect demo code', () {
    final auth = DemoAuthService();

    expect(
      auth.validatePatientSms(rawPhone: '+7 999 000-00-02', smsCode: '111111'),
      isFalse,
    );
  });

  test('doctor credentials authenticate as doctor role', () {
    final auth = DemoAuthService();

    final session = auth.authenticateEmployee(
      login: '+7 999 000-10-01',
      password: 'Doctor57!',
    );

    expect(session?.userId, 'doctor_001');
    expect(session?.role, UserRole.doctor);
  });

  test('admin credentials authenticate as administrator role', () {
    final auth = DemoAuthService();

    final session = auth.authenticateEmployee(
      login: 'admin57',
      password: 'Grani57Demo!',
    );

    expect(session?.userId, 'admin_001');
    expect(session?.role, UserRole.administrator);
  });

  test('invalid employee credentials are rejected', () {
    final auth = DemoAuthService();

    final session = auth.authenticateEmployee(
      login: 'admin57',
      password: 'wrong-password',
    );

    expect(session, isNull);
  });

  test(
    'demo session save restore and clear use minimal persisted state',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = DemoSessionStore(preferences: preferences);
      const session = DemoSession.authenticated(
        userId: 'patient_001',
        role: UserRole.patient,
      );

      await store.saveSession(session);
      final restored = await store.restoreSession();

      expect(restored.isAuthenticated, isTrue);
      expect(restored.userId, 'patient_001');
      expect(restored.role, UserRole.patient);
      expect(preferences.getString('demo_session.password'), isNull);
      expect(preferences.getString('demo_session.sms_code'), isNull);

      await store.clearSession();
      final cleared = await store.restoreSession();

      expect(cleared.isAuthenticated, isFalse);
      expect(cleared.userId, isNull);
      expect(cleared.role, isNull);
    },
  );

  test('doctor schedule references existing demo patients', () {
    final patientIds = DemoPatients.values.map((patient) => patient.id).toSet();

    expect(DemoSchedule.appointments, hasLength(3));
    for (final appointment in DemoSchedule.appointments) {
      expect(appointment.doctorId, 'doctor_001');
      expect(patientIds, contains(appointment.patientId));
    }
    expect(DemoSchedule.appointmentsForDay(DemoSchedule.emptyWorkday), isEmpty);
  });

  testWidgets('representative raster asset is bundled', (tester) async {
    final data = await rootBundle.load(DemoAssetPaths.representativeRaster);

    expect(data.lengthInBytes, greaterThan(0));
  });

  testWidgets('representative SVG renders through flutter_svg', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.asset(DemoAssetPaths.representativeSvg),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('navigation SVG with Figma filter markup renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.asset(DemoAssetPaths.navigationSvgWithFigmaFilter),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('AppButton exposes disabled and loading states', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              AppButton(label: 'Disabled action', onPressed: null),
              AppButton(
                label: 'Loading action',
                onPressed: _noop,
                isLoading: true,
              ),
            ],
          ),
        ),
      ),
    );

    final disabledButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Disabled action'),
    );

    expect(disabledButton.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading action'), findsNothing);
  });
}

Future<void> _pumpStartupWithSession(
  WidgetTester tester,
  DemoSession session,
) async {
  await tester.pumpWidget(
    Grani57App(
      restoreSession: () async => session,
      minimumSplashDuration: Duration.zero,
      splashFadeDuration: Duration.zero,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpPatientLogin(
  WidgetTester tester, {
  DemoSessionStore? sessionStore,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: AppTheme.light,
      home: PatientPhoneLoginScreen(sessionStore: sessionStore),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _submitPhone(WidgetTester tester, String phone) async {
  await tester.enterText(find.byType(TextField).first, phone);
  await tester.tap(find.text('Получить код'));
  await tester.pumpAndSettle();
}

Future<void> _openSmsForPhone(
  WidgetTester tester,
  String phone, {
  DemoSessionStore? sessionStore,
}) async {
  await _pumpPatientLogin(tester, sessionStore: sessionStore);
  await _submitPhone(tester, phone);
}

Future<void> _submitSms(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField).last, code);
  await tester.tap(find.text('Войти'));
  await tester.pumpAndSettle();
}

Future<SharedPreferences> _loginWithSms(
  WidgetTester tester, {
  required String phone,
  required String code,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  await _openSmsForPhone(
    tester,
    phone,
    sessionStore: DemoSessionStore(preferences: preferences),
  );
  await _submitSms(tester, code);
  return preferences;
}

void _noop() {}
