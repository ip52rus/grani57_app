import 'package:flutter/widgets.dart';

import '../../core/mock_runtime/demo_auth_service.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../doctor_auth/doctor_login_screen.dart';

/// Compatibility entry used by the existing patient-auth employee action.
class EmployeeAuthPlaceholder extends StatelessWidget {
  const EmployeeAuthPlaceholder({
    super.key,
    this.authService,
    this.sessionStore,
  });

  final DemoAuthService? authService;
  final DemoSessionStore? sessionStore;

  @override
  Widget build(BuildContext context) =>
      DoctorLoginScreen(authService: authService, sessionStore: sessionStore);
}
