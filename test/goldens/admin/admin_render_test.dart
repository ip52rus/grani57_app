import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/core/mock_runtime/admin_demo_store.dart';
import 'package:grani57_app/core/mock_runtime/doctor_access_store.dart';
import 'package:grani57_app/features/admin/admin_doctor_access_screen.dart';
import 'package:grani57_app/features/admin/admin_doctors_screen.dart';
import 'package:grani57_app/features/admin/admin_publications_screen.dart';
import 'package:grani57_app/features/admin/admin_shell_screen.dart';
import 'package:grani57_app/features/doctor_auth/doctor_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadManropeFonts();
    for (final name in const [
      'admin_login',
      'admin_home',
      'admin_publications',
      'admin_publication_new',
      'admin_publication_edit',
      'admin_publication_delete',
      'admin_doctors',
      'admin_doctor_new',
      'admin_doctor_edit',
      'admin_doctor_delete',
      'admin_doctor_access_create',
      'admin_doctor_access_existing',
    ]) {
      _copyReference(
        source: 'docs/figma_reference/admin/$name.png',
        target: 'docs/visual_tests/admin/${name}_figma.png',
      );
    }
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders admin employee login', (tester) async {
    await _render(
      tester,
      name: 'admin_login',
      child: const DoctorLoginScreen(),
    );
  });

  testWidgets('renders admin home', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_home',
      child: AdminShellScreen(store: state.store, accessStore: state.access),
    );
  });

  testWidgets('renders publications list', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_publications',
      child: AdminShellScreen(
        store: state.store,
        accessStore: state.access,
        initialTab: 1,
      ),
    );
  });

  testWidgets('renders new publication', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_publication_new',
      child: AdminPublicationFormScreen(store: state.store),
    );
  });

  testWidgets('renders edit publication', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_publication_edit',
      child: AdminPublicationFormScreen(
        store: state.store,
        publication: state.store.publications.first,
      ),
    );
  });

  testWidgets('renders publication delete state', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_publication_delete',
      child: AdminShellScreen(
        store: state.store,
        accessStore: state.access,
        initialTab: 1,
      ),
      interact: (tester) async {
        await tester.tap(find.text('Удалить').first);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('renders doctors list', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_doctors',
      child: AdminShellScreen(
        store: state.store,
        accessStore: state.access,
        initialTab: 2,
      ),
    );
  });

  testWidgets('renders new doctor', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_doctor_new',
      child: AdminDoctorFormScreen(
        store: state.store,
        accessStore: state.access,
      ),
    );
  });

  testWidgets('renders edit doctor', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_doctor_edit',
      child: AdminDoctorFormScreen(
        store: state.store,
        accessStore: state.access,
        doctor: state.store.doctors.first,
      ),
    );
  });

  testWidgets('renders doctor delete state', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_doctor_delete',
      child: AdminShellScreen(
        store: state.store,
        accessStore: state.access,
        initialTab: 2,
      ),
      interact: (tester) async {
        await tester.tap(find.text('Удалить').first);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('renders doctor access creation', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_doctor_access_create',
      child: AdminDoctorAccessScreen(
        doctor: state.store.doctors[1],
        accessStore: state.access,
      ),
    );
  });

  testWidgets('renders existing doctor access', (tester) async {
    final state = await _state();
    await _render(
      tester,
      name: 'admin_doctor_access_existing',
      child: AdminDoctorAccessScreen(
        doctor: state.store.doctors.first,
        accessStore: state.access,
      ),
    );
  });
}

Future<_AdminState> _state() async {
  final preferences = await SharedPreferences.getInstance();
  final store = AdminDemoStore(preferences: preferences);
  final access = DoctorAccessStore(preferences: preferences);
  await store.initialize();
  await access.initialize();
  return _AdminState(store, access);
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
  required String name,
  required Widget child,
  Future<void> Function(WidgetTester tester)? interact,
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
  if (interact != null) await interact(tester);

  await expectLater(
    find.byKey(repaintKey),
    matchesGoldenFile(
      Uri.file(
        File('docs/visual_tests/admin/${name}_flutter.png').absolute.path,
      ),
    ),
  );
}

class _AdminState {
  const _AdminState(this.store, this.access);

  final AdminDemoStore store;
  final DoctorAccessStore access;
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
