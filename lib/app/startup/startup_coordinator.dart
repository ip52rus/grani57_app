import 'package:flutter/material.dart';

import '../../core/mock_runtime/demo_session.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import 'splash_screen.dart';
import 'startup_destination.dart';

typedef RestoreDemoSession = Future<DemoSession> Function();

class StartupCoordinator extends StatefulWidget {
  const StartupCoordinator({
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

  @override
  State<StartupCoordinator> createState() => _StartupCoordinatorState();
}

class _StartupCoordinatorState extends State<StartupCoordinator> {
  late final DemoSessionStore _sessionStore;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _sessionStore = widget.sessionStore ?? DemoSessionStore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }

    _started = true;
    _runStartup();
  }

  Future<void> _runStartup() async {
    final restoreFuture = _restoreSession();
    final minimumSplashFuture = Future<void>.delayed(
      _effectiveMinimumSplashDuration(),
    );

    final results = await Future.wait<dynamic>([
      restoreFuture,
      minimumSplashFuture,
    ]);

    if (!mounted) {
      return;
    }

    final session = results.first as DemoSession;
    final destination = destinationForSession(session);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => widgetForStartupDestination(destination),
      ),
    );
  }

  Future<DemoSession> _restoreSession() async {
    try {
      final restoreSession = widget.restoreSession;
      if (restoreSession != null) {
        return restoreSession();
      }
      return _sessionStore.restoreSession();
    } catch (_) {
      await _sessionStore.clearSession();
      return const DemoSession.unauthenticated();
    }
  }

  Duration _effectiveMinimumSplashDuration() {
    if (MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }
    return widget.minimumSplashDuration;
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(fadeDuration: widget.splashFadeDuration);
  }
}
