import 'package:flutter/material.dart';

import '../core/design_system/theme/app_theme.dart';
import '../core/mock_runtime/demo_session_store.dart';
import 'startup/startup_coordinator.dart';

class Grani57App extends StatelessWidget {
  const Grani57App({
    super.key,
    this.sessionStore,
    this.restoreSession,
    this.minimumSplashDuration = const Duration(milliseconds: 2300),
    this.splashFadeDuration = const Duration(milliseconds: 1500),
  });

  final DemoSessionStore? sessionStore;
  final RestoreDemoSession? restoreSession;
  final Duration minimumSplashDuration;
  final Duration splashFadeDuration;

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: '57 ГРАНЕЙ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const MaterialScrollBehavior(),
      home: StartupCoordinator(
        sessionStore: sessionStore,
        restoreSession: restoreSession,
        minimumSplashDuration: minimumSplashDuration,
        splashFadeDuration: splashFadeDuration,
      ),
    );
  }
}
