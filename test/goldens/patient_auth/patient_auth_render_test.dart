import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/core/mock_runtime/demo_auth_service.dart';
import 'package:grani57_app/core/mock_runtime/demo_session_store.dart';
import 'package:grani57_app/features/patient_auth/patient_phone_login_screen.dart';
import 'package:grani57_app/features/patient_auth/patient_sms_code_screen.dart';

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
  });

  testWidgets('renders canonical patient login screenshot', (tester) async {
    await _renderScreen(
      tester,
      filePath: 'docs/visual_tests/patient_auth/login_flutter.png',
      child: const PatientPhoneLoginScreen(),
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
                padding: EdgeInsets.only(top: 44),
                textScaler: TextScaler.noScaling,
              ),
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
