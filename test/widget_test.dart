import 'package:flutter/cupertino.dart';
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
import 'package:grani57_app/core/navigation/app_page_route.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/core/design_system/tokens/app_colors.dart';
import 'package:grani57_app/core/design_system/tokens/app_spacing.dart';
import 'package:grani57_app/core/design_system/typography/app_typography.dart';
import 'package:grani57_app/features/patient_auth/patient_phone_login_screen.dart';
import 'package:grani57_app/features/patient_auth/patient_consent_screen.dart';
import 'package:grani57_app/features/patient_auth/patient_new_data_screen.dart';
import 'package:grani57_app/features/patient_auth/russian_phone_input_formatter.dart';
import 'package:grani57_app/features/patient_appointments/patient_appointment_details_screen.dart';
import 'package:grani57_app/features/patient_appointments/patient_appointment_cancel_screen.dart';
import 'package:grani57_app/features/patient_appointments/patient_appointments_screen.dart';
import 'package:grani57_app/features/patient_appointments/patient_appointment_reschedule_screen.dart';
import 'package:grani57_app/features/patient_appointments/patient_appointment_rescheduled_screen.dart';
import 'package:grani57_app/features/patient_clinics/patient_clinics_screen.dart';
import 'package:grani57_app/features/patient_documents/patient_conclusion_pdf_screen.dart';
import 'package:grani57_app/features/patient_documents/patient_conclusion_screen.dart';
import 'package:grani57_app/features/patient_documents/patient_document_pdf_service.dart';
import 'package:grani57_app/features/patient_documents/patient_documents_screen.dart';
import 'package:grani57_app/features/patient_home/patient_home_screen.dart';
import 'package:grani57_app/features/patient_home/patient_news_screen.dart';
import 'package:grani57_app/features/patient_booking/patient_booking_screens.dart';
import 'package:grani57_app/features/development_demo/patient_shell_placeholder.dart';
import 'package:grani57_app/mock_data/demo_asset_paths.dart';
import 'package:grani57_app/mock_data/demo_patient_documents.dart';
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

    expect(find.text('Вход и регистрация'), findsOneWidget);
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

    expect(logoSvg, contains('viewBox="0 0 260 74.5307"'));
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

    expect(find.text('Вход и регистрация'), findsOneWidget);
  });

  testWidgets('patient session routes to patient home', (tester) async {
    await _pumpStartupWithSession(
      tester,
      const DemoSession.authenticated(
        userId: 'patient_001',
        role: UserRole.patient,
      ),
    );

    expect(find.text('Здравствуйте, Иван'), findsOneWidget);
    expect(find.text('БЛИЖАЙШИЙ ПРИЁМ'), findsOneWidget);
  });

  testWidgets('home news counter follows the active carousel card', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PatientHomeScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('01 / 02'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('patient.home.news.carousel')),
      const Offset(-120, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('01 / 02'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('patient.home.news.carousel')),
      const Offset(-220, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('02 / 02'), findsOneWidget);
  });

  testWidgets('opening a home news card shows its article', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PatientHomeScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Открыть новость').first);
    await tester.pumpAndSettle();

    expect(find.byType(PatientNewsScreen), findsOneWidget);
    expect(find.text('Забота начинается'), findsOneWidget);
    expect(find.text('Записаться на приём'), findsOneWidget);
  });

  testWidgets('home booking action starts the clinic selection flow', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PatientHomeScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Записаться на приём').first);
    await tester.pumpAndSettle();

    expect(find.byType(PatientBookingClinicScreen), findsOneWidget);
    expect(find.text('Выберите клинику'), findsOneWidget);
    expect(find.text('Шаг 1 из 4'), findsOneWidget);
  });

  testWidgets('home upcoming appointment opens appointment details', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientHomeScreen(
          patientId: 'patient_001',
          homeState: PatientHomeState.upcomingAppointment,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Посмотреть запись'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientAppointmentDetailsScreen), findsOneWidget);
    expect(find.text('14 сентября · 10:30'), findsOneWidget);
    expect(find.text('Анна Смирнова'), findsOneWidget);
  });

  testWidgets('appointments tabs switch by tap and selected-segment swipe', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientAppointmentsScreen(patientId: 'patient_001'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ваши приёмы'), findsOneWidget);
    expect(find.text('14 сентября · 10:30'), findsOneWidget);
    expect(find.text('Оплаты и чеки'), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('patient.appointments.mode_switch')),
      const Offset(100, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('История лечения'), findsOneWidget);
    expect(find.text('Заключение врача'), findsNWidgets(2));
    expect(find.text('Приём завершён'), findsOneWidget);
    expect(find.text('Приём отменён'), findsOneWidget);
    expect(find.text('Посмотреть документы'), findsNothing);
    expect(find.textContaining('₽'), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('patient.appointments.mode_switch')),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ваши приёмы'), findsOneWidget);

    await tester.tap(find.text('История'));
    await tester.pumpAndSettle();
    expect(find.text('История лечения'), findsOneWidget);
  });

  testWidgets('documents tab opens conclusion and PDF states', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: PatientShellPlaceholder(
          patientId: 'patient_001',
          patientName: 'Иван Петров',
        ),
      ),
    );
    await tester.pumpAndSettle();
    tester.takeException();

    await tester.tap(find.text('Документы'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientDocumentsScreen), findsOneWidget);
    expect(find.text('Всё о вашем лечении'), findsOneWidget);
    expect(find.text('Все документы'), findsNothing);
    expect(find.text('Заключения'), findsNothing);
    expect(find.text('Заключение врача'), findsNWidgets(2));
    expect(find.text('Рекомендации после приёма'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Заключение врача').first);
    await tester.pumpAndSettle();

    expect(find.byType(PatientConclusionScreen), findsOneWidget);
    expect(find.text('Иван Петров'), findsOneWidget);
    expect(find.text('Подписано врачом'), findsOneWidget);
    expect(find.text('Профессиональная гигиена'), findsOneWidget);
    expect(tester.takeException(), isNull);

    expect(find.text('Открыть оригинал PDF'), findsNothing);
    await tester.tap(find.text('Скачать заключение'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientConclusionPdfScreen), findsOneWidget);
    expect(find.text('Заключение · PDF'), findsOneWidget);
    expect(find.text('Иван Петров'), findsOneWidget);
    expect(find.text('ЗАКЛЮЧЕНИЕ ВРАЧА'), findsOneWidget);
    expect(find.text('Сохранить PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appointment history conclusion opens the document screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PatientAppointmentsScreen(
          patientId: 'patient_001',
          patientName: 'Иван Петров',
          showHistoryInitially: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Заключение врача').first);
    await tester.pumpAndSettle();

    expect(find.byType(PatientConclusionScreen), findsOneWidget);
    expect(find.text('Иван Петров'), findsOneWidget);
    expect(find.text('22 августа 2026 · приём завершён'), findsOneWidget);
  });

  testWidgets('builds a downloadable patient conclusion PDF', (tester) async {
    final bytes = await PatientDocumentPdfService.buildConclusion(
      document: DemoPatientDocuments.items.first,
      patientName: 'Иван Петров',
    );

    expect(bytes.length, greaterThan(1000));
    expect(bytes.sublist(0, 4), const [0x25, 0x50, 0x44, 0x46]);
  });

  testWidgets('appointment details button opens the Figma details screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientAppointmentsScreen(patientId: 'patient_001'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Детали приёма'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientAppointmentDetailsScreen), findsOneWidget);
    expect(find.text('14 сентября · 10:30'), findsOneWidget);
    expect(find.text('Продолжительность · 30 минут'), findsNothing);
    expect(find.text('Анна Смирнова'), findsOneWidget);
    expect(find.text('Консультация стоматолога'), findsOneWidget);
    expect(find.text('Как добраться'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Назад к приёмам'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientAppointmentsScreen), findsOneWidget);
  });

  testWidgets('appointment can be cancelled through the Figma cancel screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientAppointmentsScreen(patientId: 'patient_001'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Детали приёма'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Отменить запись'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отменить запись'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientAppointmentCancelScreen), findsOneWidget);
    expect(find.text('Отменить приём?'), findsOneWidget);
    expect(
      find.text('14 сентября · 10:30\nКонсультация · Анна Смирнова'),
      findsOneWidget,
    );
    expect(find.text('Сохранить запись'), findsOneWidget);
    expect(find.text('Выбрать другое время'), findsOneWidget);
    expect(find.text('Да, отменить приём'), findsOneWidget);

    await tester.ensureVisible(find.text('Да, отменить приём'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Да, отменить приём'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientAppointmentsScreen), findsOneWidget);
    expect(find.text('Пока нет записей'), findsOneWidget);
  });

  testWidgets('appointment reschedule reuses calendar and time controls', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientAppointmentsScreen(patientId: 'patient_001'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Детали приёма'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Перенести приём'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Перенести приём'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientAppointmentRescheduleScreen), findsOneWidget);
    expect(find.byType(PatientBookingCalendar), findsOneWidget);
    expect(find.byType(PatientBookingTimeGrid), findsOneWidget);
    expect(find.text('14 сентября · 10:30'), findsOneWidget);
    expect(find.text('15 сентября · 12:00'), findsOneWidget);

    await tester.tap(find.text('Подтвердить перенос'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientAppointmentRescheduledScreen), findsOneWidget);
    expect(find.text('Запись обновлена'), findsOneWidget);
    expect(find.text('Приём перенесён'), findsOneWidget);
    expect(find.text('Новое время подтверждено'), findsOneWidget);
    expect(find.text('15 сентября · 12:00'), findsOneWidget);
    expect(find.text('14 сентября · 10:30'), findsNothing);
    expect(
      find.text(
        'Прежняя запись на 14 сентября отменена. '
        'Напомним о новом времени заранее.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('К моим приёмам'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientAppointmentsScreen), findsOneWidget);
    expect(find.text('15 сентября · 12:00'), findsOneWidget);
  });

  testWidgets('appointments show an empty card for either empty tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientAppointmentsScreen(patientId: 'patient_003'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Пока нет записей'), findsOneWidget);
    await tester.tap(find.text('История'));
    await tester.pumpAndSettle();
    expect(find.text('Пока нет записей'), findsOneWidget);
  });

  testWidgets('patient bottom navigation opens appointments', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientShellPlaceholder(patientId: 'patient_001'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Приёмы').last);
    await tester.pumpAndSettle();

    expect(find.byType(PatientAppointmentsScreen), findsOneWidget);
    expect(find.text('Мои приёмы'), findsOneWidget);
  });

  testWidgets('patient bottom navigation opens clinics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientShellPlaceholder(patientId: 'patient_001'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Клиники').last);
    await tester.pumpAndSettle();

    expect(find.byType(PatientClinicsScreen), findsOneWidget);
    expect(find.text('Мы рядом'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('На Просвещения'), findsOneWidget);
    expect(find.text('На Большеохтинском'), findsOneWidget);
    expect(find.textContaining('Запись открыта'), findsNothing);
    expect(find.text('Скоро открытие'), findsOneWidget);
    expect(find.textContaining('2 ·'), findsNothing);
  });

  testWidgets('booking mode selector follows selected segment drag direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientBookingServiceScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('patient.booking.mode_switch')),
      const Offset(100, 0),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Любой специалист'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('patient.booking.mode_switch')),
      const Offset(-100, 0),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Лечение зубов'), findsOneWidget);

    await tester.tap(find.text('К врачу'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Любой специалист'), findsOneWidget);
  });

  testWidgets('selected booking doctor is shown on the date and time step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientBookingServiceScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('К врачу'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Алексей Волков'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Алексей Волков'));
    await tester.pump();
    await tester.tap(find.text('Выбрать дату и время'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientBookingDateTimeScreen), findsOneWidget);
    expect(find.text('Алексей Волков'), findsOneWidget);
    expect(find.text('Анна Смирнова'), findsNothing);
  });

  testWidgets('booking calendar changes month and time slots scroll', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientBookingDateTimeScreen(draft: BookingDraft()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('›'));
    await tester.pumpAndSettle();
    expect(find.text('Октября 2026'), findsOneWidget);

    final timeSlots = find.byKey(const ValueKey('patient.booking.time_slots'));
    await tester.ensureVisible(timeSlots);
    await tester.drag(timeSlots, const Offset(-900, 0));
    await tester.pumpAndSettle();
    expect(find.text('21:00'), findsOneWidget);
  });

  testWidgets('booking confirmation opens the successful result state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientBookingConfirmationScreen(draft: BookingDraft()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Подтвердить запись'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientBookingSuccessScreen), findsOneWidget);
    expect(find.text('Вы записаны'), findsOneWidget);
    expect(find.text('14 сентября · 10:30'), findsOneWidget);
  });

  testWidgets('booking confirmation opens the offline result state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: PatientBookingConfirmationScreen(
          draft: const BookingDraft(),
          submitBooking: (_) async => BookingSubmissionResult.offline,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Подтвердить запись'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientBookingOfflineScreen), findsOneWidget);
    expect(find.text('Проверить статус'), findsOneWidget);
  });

  testWidgets('booking confirmation opens the occupied-time result state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: PatientBookingConfirmationScreen(
          draft: const BookingDraft(),
          submitBooking: (_) async => BookingSubmissionResult.timeUnavailable,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Подтвердить запись'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientBookingTimeUnavailableScreen), findsOneWidget);
    expect(find.text('Выбрать другое время'), findsOneWidget);
  });

  testWidgets('Alexey booking shows offline state then occupied-time status', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientBookingConfirmationScreen(
          draft: BookingDraft(
            patientId: 'patient_003',
            patientName: 'Алексей Орлов',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Алексей Орлов'), findsOneWidget);
    await tester.tap(find.text('Подтвердить запись'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientBookingOfflineScreen), findsOneWidget);

    await tester.tap(find.text('Проверить статус'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientBookingTimeUnavailableScreen), findsOneWidget);
    expect(find.text('Это время уже занято'), findsOneWidget);

    await tester.tap(find.text('Выбрать другое время'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientBookingDateTimeScreen), findsOneWidget);
    expect(find.text('Когда Вам удобно?'), findsOneWidget);
  });

  testWidgets('long patient greeting wraps the name without scaling it down', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PatientHomeScreen(patientName: 'Алексей'),
      ),
    );
    await tester.pumpAndSettle();

    final greeting = find.text('Здравствуйте, Алексей');
    expect(greeting, findsOneWidget);
    expect(tester.getSize(greeting).height, greaterThan(36));
    expect(tester.widget<Text>(greeting).style?.fontSize, 32);
    expect(tester.takeException(), isNull);
  });

  testWidgets('doctor session routes to doctor schedule', (tester) async {
    await _pumpStartupWithSession(
      tester,
      const DemoSession.authenticated(
        userId: 'doctor_001',
        role: UserRole.doctor,
      ),
    );

    expect(find.text('Кабинет врача'), findsOneWidget);
    expect(find.text('Анна Смирнова'), findsOneWidget);
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

    expect(find.text('Вход и регистрация'), findsOneWidget);
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
    expect(find.text('Здравствуйте, Иван'), findsOneWidget);
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
    expect(formatRussianPhone('+79990000001'), '+7 (999) 000-00-01');
    expect(formatRussianPhone('89990000001'), '+7 (999) 000-00-01');
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

    expect(find.text('Вход и регистрация'), findsOneWidget);
    expect(find.text('Номер телефона'), findsOneWidget);
    expect(find.text('Получить код'), findsOneWidget);
    expect(find.text('Вход для сотрудников'), findsOneWidget);
  });

  testWidgets('empty phone submission shows the Figma error field state', (
    tester,
  ) async {
    await _pumpPatientLogin(tester);

    expect(find.text('+7 '), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('patient.phone.input')))
          .decoration!
          .hintText,
      '(___) ___-__-__',
    );

    await tester.tap(find.byKey(const ValueKey('patient.consent.checkbox')));
    await tester.pump();
    await tester.tap(find.text('Получить код'));
    await tester.pump();

    final surface = tester.widget<Container>(
      find.byKey(const ValueKey('patient.phone.field.surface')),
    );
    final decoration = surface.decoration! as BoxDecoration;
    final border = decoration.border! as Border;

    expect(border.top.color, AppColors.error);
    expect(find.text('Введите номер телефона'), findsOneWidget);
  });

  testWidgets('consent is required and its document opens separately', (
    tester,
  ) async {
    await _pumpPatientLogin(tester);

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Получить код'),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('patient.consent.checkbox')));
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Получить код'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const ValueKey('patient.consent.document')));
    await tester.pumpAndSettle();
    expect(find.byType(PatientConsentScreen), findsOneWidget);
    expect(find.text('Проект документа · для согласования'), findsOneWidget);
  });

  testWidgets('iOS uses the standard Cupertino route for back navigation', (
    tester,
  ) async {
    late Route<void> route;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            route = appPageRoute<void>(
              context,
              builder: (_) => const PatientConsentScreen(),
              platform: TargetPlatform.iOS,
            );
            return const SizedBox();
          },
        ),
      ),
    );

    expect(route, isA<CupertinoPageRoute<void>>());
  });

  testWidgets('back swipe starts within the left forty percent of the screen', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              appPageRoute<void>(
                context,
                platform: TargetPlatform.iOS,
                builder: (_) => const Scaffold(body: Text('Второй экран')),
              ),
            ),
            child: const Text('Открыть экран'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Открыть экран'));
    await tester.pumpAndSettle();
    expect(find.text('Второй экран'), findsOneWidget);

    await tester.dragFrom(const Offset(140, 300), const Offset(90, 0));
    await tester.pumpAndSettle();

    expect(find.text('Открыть экран'), findsOneWidget);
    expect(find.text('Второй экран'), findsNothing);
  });

  testWidgets('Patient auth screens fit reference widths and input behavior', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final width in <double>[360, 393, 430]) {
      tester.view.physicalSize = Size(width, 852);
      await _pumpPatientLogin(tester);

      final phoneField = tester.widget<TextField>(
        find.byKey(const ValueKey('patient.phone.input')),
      );
      expect(phoneField.keyboardType, TextInputType.phone);
      expect(phoneField.enableInteractiveSelection, isTrue);
      expect(tester.takeException(), isNull);

      await _submitPhone(tester, '+7 999 000-00-01');
      final smsField = tester.widget<TextField>(
        find.byKey(const ValueKey('patient.sms.input')),
      );
      expect(smsField.keyboardType, TextInputType.number);
      expect(smsField.autofillHints, contains(AutofillHints.oneTimeCode));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('known patient opens SMS screen', (tester) async {
    await _openSmsForPhone(tester, '+7 999 000-00-01');

    expect(find.text('Подтверждение номера'), findsOneWidget);
    expect(find.textContaining('+7 (999) 000-00-01'), findsOneWidget);
  });

  testWidgets('unknown phone opens new patient data after verified SMS', (
    tester,
  ) async {
    await _openSmsForPhone(tester, '+7 999 000-99-99');
    await _submitSms(tester, '111111');

    expect(find.byType(PatientNewDataScreen), findsOneWidget);
    expect(find.text('Регистрация'), findsOneWidget);
    expect(find.byTooltip('Назад'), findsNothing);
    expect(find.text('Подтверждение номера'), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  testWidgets(
    'new patient fields use text keyboard and valid manual birth date',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: PatientNewDataScreen(
            phone: '+7 (999) 000-99-99',
            sessionStore: DemoSessionStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nameField = tester.widget<TextField>(
        find.byKey(const ValueKey('patient.new_data.name.input')),
      );
      expect(nameField.keyboardType, TextInputType.name);
      await tester.enterText(
        find.byKey(const ValueKey('patient.new_data.name.input')),
        'Петрова Мария',
      );
      await tester.pump();

      final birthDateField = find.byKey(
        const ValueKey('patient.new_data.birth_date.input'),
      );
      await tester.enterText(birthDateField, '3102');
      await tester.pump();
      expect(find.text('31.0'), findsOneWidget);
      await tester.enterText(birthDateField, '29022024');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(find.text('29.02.2024'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Продолжить'))
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('correct SMS patient_001 saves session and routes to shell', (
    tester,
  ) async {
    final preferences = await _loginWithSms(
      tester,
      phone: '+7 999 000-00-01',
      code: '111111',
    );

    expect(find.text('Здравствуйте, Иван'), findsOneWidget);
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Иван Петров'), findsOneWidget);
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

    expect(find.text('Здравствуйте, Мария'), findsOneWidget);
    expect(find.text('Приём завершён'), findsOneWidget);
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Мария Соколова'), findsOneWidget);
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

    expect(find.text('Здравствуйте, Алексей'), findsOneWidget);
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Алексей Орлов'), findsOneWidget);
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
    expect(find.text('Подтверждение номера'), findsOneWidget);
    expect(preferences.getBool('demo_session.is_authenticated'), isNull);
  });

  testWidgets('Back from SMS returns to Login', (tester) async {
    await _openSmsForPhone(tester, '+7 999 000-00-01');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Вход и регистрация'), findsOneWidget);
    expect(find.text('Подтверждение номера'), findsNothing);
  });

  testWidgets('Back after successful authentication does not return to auth', (
    tester,
  ) async {
    await _loginWithSms(tester, phone: '+7 999 000-00-01', code: '111111');

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(find.text('Здравствуйте, Иван'), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('employee link opens doctor login', (tester) async {
    await _pumpPatientLogin(tester);

    await tester.ensureVisible(find.text('Вход для сотрудников'));
    await tester.tap(find.text('Вход для сотрудников'));
    await tester.pumpAndSettle();

    expect(find.text('Кабинет врача'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
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

    expect(find.text('Здравствуйте, Иван'), findsOneWidget);
    expect(find.text('Вход и регистрация'), findsNothing);
  });

  testWidgets('Profile shows session phone and signs out of the demo session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final sessionStore = DemoSessionStore(preferences: preferences);
    const session = DemoSession.authenticated(
      userId: 'patient_001',
      role: UserRole.patient,
      phone: '+7 (921) 000-00-00',
    );
    await sessionStore.saveSession(session);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: PatientShellPlaceholder(
          sessionStore: sessionStore,
          patientId: session.userId,
          phone: session.phone,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Профиль'), findsNWidgets(2));
    expect(find.text('+7 (921) 000-00-00'), findsOneWidget);
    expect(find.text('Иван Петров'), findsOneWidget);

    await tester.tap(find.text('Выйти из аккаунта'));
    await tester.pumpAndSettle();

    expect(find.text('Вход и регистрация'), findsOneWidget);
    final restored = await sessionStore.restoreSession();
    expect(restored.isAuthenticated, isFalse);
    expect(restored.phone, isNull);
  });

  test('SMS validation accepts registered demo code', () {
    final auth = DemoAuthService();

    expect(
      auth.validatePatientSms(rawPhone: '+7 999 000-00-02', smsCode: '222222'),
      isTrue,
    );
  });

  test('patient authentication keeps the entered phone for the profile', () {
    final session = DemoAuthService().authenticateRegisteredPatient(
      rawPhone: '+7 999 000-00-01',
      smsCode: '111111',
    );

    expect(session?.phone, '+7 (999) 000-00-01');
  });

  test('SMS validation rejects incorrect demo code', () {
    final auth = DemoAuthService();

    expect(
      auth.validatePatientSms(rawPhone: '+7 999 000-00-02', smsCode: '111111'),
      isFalse,
    );
  });

  test('doctor credentials authenticate as doctor role', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = DemoAuthService();

    final session = await auth.authenticateEmployee(
      login: '+7 999 000-10-01',
      password: 'Doctor57!',
    );

    expect(session?.userId, 'doctor_001');
    expect(session?.role, UserRole.doctor);
  });

  test('admin credentials authenticate as administrator role', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = DemoAuthService();

    final session = await auth.authenticateEmployee(
      login: 'admin57',
      password: 'Grani57Demo!',
    );

    expect(session?.userId, 'admin_001');
    expect(session?.role, UserRole.administrator);
  });

  test('invalid employee credentials are rejected', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = DemoAuthService();

    final session = await auth.authenticateEmployee(
      login: 'admin57',
      password: 'wrong-password',
    );

    expect(session, isNull);
  });

  test(
    'demo session save restore and clear persist only the needed profile data',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = DemoSessionStore(preferences: preferences);
      const session = DemoSession.authenticated(
        userId: 'patient_001',
        role: UserRole.patient,
        phone: '+7 (999) 000-00-01',
        name: 'Иван Петров',
      );

      await store.saveSession(session);
      final restored = await store.restoreSession();

      expect(restored.isAuthenticated, isTrue);
      expect(restored.userId, 'patient_001');
      expect(restored.role, UserRole.patient);
      expect(restored.phone, '+7 (999) 000-00-01');
      expect(restored.name, 'Иван Петров');
      expect(preferences.getString('demo_session.password'), isNull);
      expect(preferences.getString('demo_session.sms_code'), isNull);

      await store.clearSession();
      final cleared = await store.restoreSession();

      expect(cleared.isAuthenticated, isFalse);
      expect(cleared.userId, isNull);
      expect(cleared.role, isNull);
      expect(cleared.phone, isNull);
      expect(cleared.name, isNull);
    },
  );

  test('doctor schedule contains the deterministic Figma workday', () {
    final workday = DemoSchedule.appointmentsForDay(
      DemoSchedule.selectedWorkday,
    );

    expect(workday, hasLength(3));
    for (final appointment in workday) {
      expect(appointment.doctorId, 'doctor_001');
    }
    expect(DemoSchedule.featuredAppointment.patientName, 'Мария Петрова');
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
  await _enterDigits(
    tester,
    'patient.phone.input',
    phone.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^7|^8'), ''),
  );
  final checkbox = find.byKey(const ValueKey('patient.consent.checkbox'));
  final button = tester.widget<TextButton>(
    find.widgetWithText(TextButton, 'Получить код'),
  );
  if (button.onPressed == null) {
    await tester.tap(checkbox);
    await tester.pump();
  }
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
  await _enterDigits(tester, 'patient.sms.input', code);
  await tester.tap(find.text('Продолжить'));
  await tester.pumpAndSettle();
}

Future<void> _enterDigits(
  WidgetTester tester,
  String fieldKey,
  String digits,
) async {
  final field = find.byKey(ValueKey(fieldKey));
  await tester.enterText(field, digits);
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
