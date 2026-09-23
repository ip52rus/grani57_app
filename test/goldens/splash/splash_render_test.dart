import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/app/startup/splash_screen.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';

void main() {
  setUpAll(_loadManropeFonts);

  testWidgets('renders canonical Splash screenshot', (tester) async {
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
              home: const MediaQuery(
                data: MediaQueryData(
                  size: Size(393, 852),
                  textScaler: TextScaler.noScaling,
                ),
                child: SplashScreen(fadeDuration: Duration.zero),
              ),
            ),
            const _FigmaStatusBar(),
          ],
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byKey(repaintKey),
      matchesGoldenFile(
        Uri.file(
          File('docs/visual_tests/splash/splash_flutter.png').absolute.path,
        ),
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
                    color: Color(0xFF172B4D),
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
