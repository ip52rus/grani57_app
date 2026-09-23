import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/core/mock_runtime/demo_auth_service.dart';
import 'package:grani57_app/core/mock_runtime/demo_session_store.dart';
import 'package:grani57_app/features/patient_auth/patient_phone_login_screen.dart';
import 'package:grani57_app/features/patient_auth/patient_consent_screen.dart';
import 'package:grani57_app/features/patient_auth/patient_new_data_screen.dart';
import 'package:grani57_app/features/patient_auth/patient_sms_code_screen.dart';
import 'package:grani57_app/features/patient_appointments/patient_appointments_screen.dart';
import 'package:grani57_app/features/patient_home/patient_home_screen.dart';
import 'package:grani57_app/features/patient_home/patient_news_screen.dart';
import 'package:grani57_app/features/patient_booking/patient_booking_screens.dart';
import 'package:grani57_app/features/patient_clinics/patient_clinics_screen.dart';
import 'package:grani57_app/features/patient_documents/patient_conclusion_pdf_screen.dart';
import 'package:grani57_app/features/patient_documents/patient_conclusion_screen.dart';
import 'package:grani57_app/features/patient_documents/patient_documents_screen.dart';
import 'package:grani57_app/features/patient_profile/patient_profile_screen.dart';
import 'package:grani57_app/mock_data/demo_asset_paths.dart';
import 'package:grani57_app/mock_data/demo_patient_documents.dart';

void main() {
  setUpAll(() async {
    await _loadManropeFonts();
    _copyReference(
      source: 'docs/figma_reference/patient_auth/login.png',
      target: 'docs/visual_tests/patient_auth/login_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/patient_auth/sms_code.png',
      target: 'docs/visual_tests/patient_auth/sms_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/patient_auth/consent.png',
      target: 'docs/visual_tests/patient_auth/consent_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/patient_auth/new_patient_data.png',
      target: 'docs/visual_tests/patient_auth/new_patient_data_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/patient_home_no_card.png',
      target: 'docs/visual_tests/patient_home_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/patient_home_appointment.png',
      target: 'docs/visual_tests/patient_home_appointment_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/patient_home_no_upcoming.png',
      target: 'docs/visual_tests/patient_home_no_upcoming_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/patient_profile.png',
      target: 'docs/visual_tests/patient_profile_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/patient_clinics/clinics.png',
      target: 'docs/visual_tests/patient_clinics/clinics_figma.png',
    );
    for (final screen in ['documents', 'conclusion', 'conclusion_pdf']) {
      _copyReference(
        source: 'docs/figma_reference/patient_documents/$screen.png',
        target: 'docs/visual_tests/patient_documents/${screen}_figma.png',
      );
    }
    for (final state in ['upcoming', 'empty', 'history']) {
      _copyReference(
        source: 'docs/figma_reference/patient_appointments_$state.png',
        target: 'docs/visual_tests/patient_appointments_${state}_figma.png',
      );
    }
    _copyReference(
      source: 'docs/figma_reference/news.png',
      target: 'docs/visual_tests/news_figma.png',
    );
    _copyReference(
      source: 'docs/figma_reference/new_branch.png',
      target: 'docs/visual_tests/new_branch_figma.png',
    );
    for (final screen in [
      'clinic',
      'service',
      'doctors',
      'datetime',
      'confirmation',
      'time_unavailable',
      'offline',
      'success',
    ]) {
      _copyReference(
        source: 'docs/figma_reference/booking_$screen.png',
        target: 'docs/visual_tests/booking_${screen}_figma.png',
      );
    }
  });

  testWidgets('renders canonical patient login screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_auth/login_flutter.png',
      mediaQueryPadding: const EdgeInsets.only(top: 59),
      child: const PatientPhoneLoginScreen(),
      beforeCapture: (tester) async {
        await _enterDigits(tester, 'patient.phone.input', '9210000000');
      },
    );
  });

  testWidgets('renders canonical patient sms screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_auth/sms_flutter.png',
      child: PatientSmsCodeScreen(
        phone: '+7 (921) 000-00-00',
        patientId: 'patient_001',
        authService: DemoAuthService(),
        sessionStore: DemoSessionStore(),
      ),
      beforeCapture: (tester) async {
        await _enterDigits(tester, 'patient.sms.input', '123456');
      },
    );
  });

  testWidgets('renders canonical patient consent screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_auth/consent_flutter.png',
      child: const PatientConsentScreen(),
    );
  });

  testWidgets('renders canonical new patient data screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_auth/new_patient_data_flutter.png',
      child: PatientNewDataScreen(
        phone: '+7 (921) 000-00-00',
        sessionStore: DemoSessionStore(),
      ),
      beforeCapture: (tester) async {
        await tester.enterText(
          find.byKey(const ValueKey('patient.new_data.name.input')),
          'Петрова Мария Сергеевна',
        );
        await _enterDigits(
          tester,
          'patient.new_data.birth_date.input',
          '12041993',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('renders canonical patient home screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_home_flutter.png',
      child: const PatientHomeScreen(),
      beforeCapture: _precacheHomeImages,
    );
  });

  testWidgets('renders patient home with an upcoming appointment', (
    tester,
  ) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_home_appointment_flutter.png',
      child: const PatientHomeScreen(
        homeState: PatientHomeState.upcomingAppointment,
      ),
      beforeCapture: _precacheHomeImages,
    );
  });

  testWidgets('renders patient home with a completed appointment', (
    tester,
  ) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_home_no_upcoming_flutter.png',
      child: const PatientHomeScreen(
        homeState: PatientHomeState.completedAppointment,
      ),
      beforeCapture: _precacheHomeImages,
    );
  });

  testWidgets('renders canonical patient profile screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_profile_flutter.png',
      child: PatientProfileScreen(
        phone: '+7 (921) 000-00-00',
        sessionStore: DemoSessionStore(),
      ),
    );
  });

  testWidgets('renders canonical patient clinics screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_clinics/clinics_flutter.png',
      child: const PatientClinicsScreen(),
      beforeCapture: (tester) async {
        final context = tester.element(find.byType(PatientClinicsScreen));
        await tester.runAsync(() async {
          await precacheImage(
            const AssetImage(
              'assets/images/maps/clinic_prosveshcheniya_map.png',
            ),
            context,
          );
        });
        await tester.pump();
      },
    );
  });

  testWidgets('renders appointments with an upcoming visit', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_appointments_upcoming_flutter.png',
      child: const PatientAppointmentsScreen(patientId: 'patient_001'),
    );
  });

  testWidgets('renders empty appointments', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_appointments_empty_flutter.png',
      child: const PatientAppointmentsScreen(patientId: 'patient_003'),
    );
  });

  testWidgets('renders appointment history', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_appointments_history_flutter.png',
      child: const PatientAppointmentsScreen(
        patientId: 'patient_001',
        showHistoryInitially: true,
      ),
    );
  });

  testWidgets('renders canonical patient documents screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_documents/documents_flutter.png',
      child: const PatientDocumentsScreen(patientName: 'Мария Петрова'),
    );
  });

  testWidgets('renders canonical patient conclusion screenshot', (
    tester,
  ) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_documents/conclusion_flutter.png',
      child: PatientConclusionScreen(
        document: DemoPatientDocuments.items.first,
        patientName: 'Мария Петрова',
      ),
      beforeCapture: (tester) async {
        final context = tester.element(find.byType(PatientConclusionScreen));
        await tester.runAsync(() async {
          await precacheImage(
            const AssetImage(DemoAssetPaths.doctorAnnaSmirnova),
            context,
          );
        });
        await tester.pump();
      },
    );
  });

  testWidgets('renders canonical patient conclusion PDF screenshot', (
    tester,
  ) async {
    await _renderScreen(
      tester,
      filePath:
          'docs/visual_tests/patient_documents/conclusion_pdf_flutter.png',
      child: PatientConclusionPdfScreen(
        document: DemoPatientDocuments.items.first,
        patientName: 'Мария Петрова',
      ),
    );
  });

  testWidgets('renders canonical introduction news screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/news_flutter.png',
      child: const PatientNewsScreen(article: PatientNewsArticle.introduction),
      beforeCapture: _precacheNewsImages,
    );
  });

  testWidgets('renders canonical new branch news screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/new_branch_flutter.png',
      child: const PatientNewsScreen(article: PatientNewsArticle.newBranch),
    );
  });

  testWidgets('renders booking clinic screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/booking_clinic_flutter.png',
      child: const PatientBookingClinicScreen(),
    );
  });

  testWidgets('renders booking service screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/booking_service_flutter.png',
      child: const PatientBookingServiceScreen(),
    );
  });

  testWidgets('renders booking doctor screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/booking_doctors_flutter.png',
      child: const PatientBookingServiceScreen(),
      beforeCapture: (tester) async {
        await tester.tap(find.text('К врачу'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('renders booking date and time screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/booking_datetime_flutter.png',
      child: const PatientBookingDateTimeScreen(draft: BookingDraft()),
    );
  });

  testWidgets('renders booking confirmation screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/booking_confirmation_flutter.png',
      child: const PatientBookingConfirmationScreen(draft: BookingDraft()),
    );
  });

  testWidgets('renders booking time unavailable screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/booking_time_unavailable_flutter.png',
      child: const PatientBookingTimeUnavailableScreen(draft: BookingDraft()),
    );
  });

  testWidgets('renders booking offline screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/booking_offline_flutter.png',
      child: PatientBookingOfflineScreen(
        draft: const BookingDraft(),
        submitBooking: (_) async => BookingSubmissionResult.offline,
      ),
    );
  });

  testWidgets('renders booking success screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/booking_success_flutter.png',
      child: const PatientBookingSuccessScreen(draft: BookingDraft()),
    );
  });
}

Future<void> _precacheHomeImages(WidgetTester tester) async {
  final context = tester.element(find.byType(PatientHomeScreen));
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage('assets/images/publications/gift_certificates.png'),
      context,
    );
    await precacheImage(
      const AssetImage('assets/images/brand/glass_tooth.png'),
      context,
    );
    await precacheImage(
      const AssetImage('assets/images/brand/glass_smile.png'),
      context,
    );
  });
  await tester.pump();
}

Future<void> _precacheNewsImages(WidgetTester tester) async {
  final context = tester.element(find.byType(PatientNewsScreen));
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage('assets/images/publications/news_glass_graphic.png'),
      context,
    );
  });
  await tester.pump();
}

Future<void> _enterDigits(
  WidgetTester tester,
  String fieldKey,
  String digits,
) async {
  final field = find.byKey(ValueKey(fieldKey));
  await tester.enterText(field, digits);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
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
  EdgeInsets mediaQueryPadding = const EdgeInsets.only(top: 44),
  Future<void> Function(WidgetTester tester)? beforeCapture,
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
              ).copyWith(padding: mediaQueryPadding),
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
  await beforeCapture?.call(tester);

  await expectLater(
    find.byKey(repaintKey),
    matchesGoldenFile(Uri.file(File(filePath).absolute.path)),
  );
}

class _FigmaStatusBar extends StatelessWidget {
  const _FigmaStatusBar();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
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
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
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
}
