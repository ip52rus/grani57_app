import 'package:flutter/widgets.dart';

import '../../core/mock_runtime/demo_session.dart';
import '../../core/mock_runtime/demo_session_store.dart';
import '../../core/mock_runtime/user_role.dart';
import '../../features/development_demo/patient_shell_placeholder.dart';
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

Widget widgetForStartupDestination(
  StartupDestination destination, {
  DemoSession? session,
  DemoSessionStore? sessionStore,
}) {
  return switch (destination) {
    StartupDestination.patientAuth => PatientAuthPlaceholder(
      sessionStore: sessionStore,
    ),
    StartupDestination.patientShell => PatientShellPlaceholder(
      sessionStore: sessionStore,
      patientId: session?.userId,
      phone: session?.phone,
      patientName: session?.name,
    ),
    StartupDestination.doctorShell => DoctorShellPlaceholder(
      sessionStore: sessionStore,
      doctorId: session?.userId,
      doctorName: session?.name,
    ),
    StartupDestination.administratorShell => AdminShellPlaceholder(
      sessionStore: sessionStore,
    ),
  };
}
