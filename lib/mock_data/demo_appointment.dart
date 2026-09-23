class DemoAppointment {
  const DemoAppointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.startsAt,
    required this.endsAt,
    required this.serviceTitle,
    required this.statusLabel,
    required this.clinic,
    required this.cabinet,
    required this.visitType,
    required this.comment,
  });

  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final DateTime startsAt;
  final DateTime endsAt;
  final String serviceTitle;
  final String statusLabel;
  final String clinic;
  final String cabinet;
  final String visitType;
  final String comment;
}
