class DemoAppointment {
  const DemoAppointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.startsAt,
    required this.serviceTitle,
  });

  final String id;
  final String doctorId;
  final String patientId;
  final DateTime startsAt;
  final String serviceTitle;
}
