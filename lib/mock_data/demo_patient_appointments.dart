class DemoPatientAppointment {
  const DemoPatientAppointment({
    required this.startsAt,
    required this.service,
    required this.doctor,
    required this.clinic,
    this.showCompletionStatus = true,
    this.isCancelled = false,
  });

  final DateTime startsAt;
  final String service;
  final String doctor;
  final String clinic;
  final bool showCompletionStatus;
  final bool isCancelled;

  DemoPatientAppointment copyWith({
    DateTime? startsAt,
    String? service,
    String? doctor,
    String? clinic,
    bool? showCompletionStatus,
    bool? isCancelled,
  }) => DemoPatientAppointment(
    startsAt: startsAt ?? this.startsAt,
    service: service ?? this.service,
    doctor: doctor ?? this.doctor,
    clinic: clinic ?? this.clinic,
    showCompletionStatus: showCompletionStatus ?? this.showCompletionStatus,
    isCancelled: isCancelled ?? this.isCancelled,
  );
}

/// Temporary patient-facing appointment data until the backend is connected.
abstract final class DemoPatientAppointments {
  static final _upcoming = <String, List<DemoPatientAppointment>>{
    'patient_001': [
      DemoPatientAppointment(
        startsAt: DateTime(2026, 9, 14, 10, 30),
        service: 'Консультация стоматолога',
        doctor: 'Анна Смирнова',
        clinic: 'пр. Просвещения, 15',
      ),
    ],
  };

  static final _history = <String, List<DemoPatientAppointment>>{
    'patient_001': _completedAppointments,
    'patient_002': _completedAppointments,
  };

  static final _completedAppointments = [
    DemoPatientAppointment(
      startsAt: DateTime(2026, 8, 22, 12),
      service: 'Профессиональная гигиена',
      doctor: 'Анна Смирнова',
      clinic: 'Просвещения, 15',
    ),
    DemoPatientAppointment(
      startsAt: DateTime(2026, 6, 18, 16),
      service: 'Консультация стоматолога',
      doctor: 'Анна Смирнова',
      clinic: 'Просвещения, 15',
      showCompletionStatus: false,
      isCancelled: true,
    ),
  ];

  static List<DemoPatientAppointment> upcomingFor(String? patientId) =>
      List.unmodifiable(_upcoming[patientId] ?? const []);

  static List<DemoPatientAppointment> historyFor(String? patientId) =>
      List.unmodifiable(_history[patientId] ?? const []);
}
