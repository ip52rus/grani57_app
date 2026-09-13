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

    expect(find.text('Patient authentication'), findsOneWidget);
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

  testWidgets('no session routes to patient auth placeholder', (tester) async {
    await _pumpStartupWithSession(tester, const DemoSession.unauthenticated());

    expect(find.text('Patient authentication'), findsOneWidget);
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

    expect(find.text('Patient authentication'), findsOneWidget);
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

void _noop() {}
