enum DemoPatientHomeState {
  noConnectedData,
  upcomingAppointment,
  completedAppointment,
}

/// Demo visit summaries drive the three patient-home states until the backend
/// provides the patient's appointment history.
abstract final class DemoPatientHome {
  static const _states = <String, DemoPatientHomeState>{
    'patient_001': DemoPatientHomeState.upcomingAppointment,
    'patient_002': DemoPatientHomeState.completedAppointment,
  };

  static DemoPatientHomeState stateForPatient(String? patientId) =>
      _states[patientId] ?? DemoPatientHomeState.noConnectedData;
}
