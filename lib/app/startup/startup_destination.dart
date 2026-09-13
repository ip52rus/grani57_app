import 'package:flutter/widgets.dart';

import '../../core/mock_runtime/demo_session.dart';
import '../../core/mock_runtime/user_role.dart';
import '../../features/development_demo/startup_placeholders.dart';

enum StartupDestination {
  patientAuth,
  patientShell,
  doctorShell,
  administratorShell,
}

StartupDestination destinationForSession(DemoSession session) {
  if (!session.isAuthenticated || !session.isValid) {
    return StartupDestination.patientAuth;
  }

  return switch (session.role) {
    UserRole.patient => StartupDestination.patientShell,
    UserRole.doctor => StartupDestination.doctorShell,
    UserRole.administrator => StartupDestination.administratorShell,
    null => StartupDestination.patientAuth,
  };
}

Widget widgetForStartupDestination(StartupDestination destination) {
  return switch (destination) {
    StartupDestination.patientAuth => const PatientAuthPlaceholder(),
    StartupDestination.patientShell => const PatientShellPlaceholder(),
    StartupDestination.doctorShell => const DoctorShellPlaceholder(),
    StartupDestination.administratorShell => const AdminShellPlaceholder(),
  };
}
