import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/features/doctor_auth/doctor_login_screen.dart';
import 'package:grani57_app/features/doctor_schedule/doctor_appointment_detail_screen.dart';
import 'package:grani57_app/features/doctor_schedule/doctor_schedule_screen.dart';
import 'package:grani57_app/mock_data/demo_schedule.dart';

void main() {
  setUpAll(() async {
    await _loadManropeFonts();
    for (final entry in const {
      'doctor_login': 'doctor_login',
      'doctor_schedule_with_appointments': 'doctor_schedule',
      'doctor_appointment_detail': 'doctor_appointment_detail',
      'doctor_schedule_empty_day': 'doctor_schedule_empty',
    }.entries) {
      _copyReference(
        source: 'docs/figma_reference/doctor_cabinet/${entry.value}.png',
        target: 'docs/visual_tests/doctor_cabinet/${entry.key}_figma.png',
      );
    }
  });

  testWidgets('renders doctor login', (tester) async {
    await _render(
      tester,
      filePath: 'docs/visual_tests/doctor_cabinet/doctor_login_flutter.png',
      child: const DoctorLoginScreen(),
    );
  });

  testWidgets('renders doctor schedule with appointments', (tester) async {
    await _render(
      tester,
      filePath:
          'docs/visual_tests/doctor_cabinet/'
          'doctor_schedule_with_appointments_flutter.png',
      child: const DoctorScheduleScreen(),
    );
  });

  testWidgets('renders doctor appointment detail', (tester) async {
    await _render(
      tester,
      filePath:
          'docs/visual_tests/doctor_cabinet/'
          'doctor_appointment_detail_flutter.png',
      child: DoctorAppointmentDetailScreen(
        appointment: DemoSchedule.featuredAppointment,
      ),
    );
  });

  testWidgets('renders doctor schedule empty-date state', (tester) async {
    await _render(
      tester,
      filePath:
          'docs/visual_tests/doctor_cabinet/'
          'doctor_schedule_empty_day_flutter.png',
      child: DoctorScheduleScreen(initialDate: DemoSchedule.emptyWorkday),
    );
  });
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

Future<void> _render(
  WidgetTester tester, {
  required Widget child,
  required String filePath,
}) async {
  final repaintKey = GlobalKey();
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(393, 852);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

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
                padding: EdgeInsets.only(top: 44),
              ),
              child: child,
            ),
          ),
          const _FigmaStatusBar(),
        ],
      ),
    ),
  );
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
                  color: Color(0xFF172B4D),
                ),
              ),
            ),
            Positioned(
              left: 302,
              top: 17,
              child: SizedBox.square(
                dimension: 10,
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
