import 'package:flutter/material.dart';

import '../core/design_system/theme/app_theme.dart';
import '../core/mock_runtime/demo_session.dart';
import 'role_gate/role_gate.dart';

class Grani57App extends StatelessWidget {
  const Grani57App({
    super.key,
    this.initialSession = const DemoSession.unauthenticated(),
  });

  final DemoSession initialSession;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '57 ГРАНЕЙ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: RoleGate(session: initialSession),
    );
  }
}
