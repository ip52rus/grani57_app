import 'package:flutter/material.dart';

import '../../core/mock_runtime/demo_session.dart';
import '../../features/development_demo/development_demo_screen.dart';

class RoleGate extends StatelessWidget {
  const RoleGate({required this.session, super.key});

  final DemoSession session;

  @override
  Widget build(BuildContext context) {
    return DevelopmentDemoScreen(session: session);
  }
}
