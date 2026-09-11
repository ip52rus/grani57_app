import 'demo_appointment.dart';
import 'demo_employees.dart';

abstract final class DemoSchedule {
  static final selectedWorkday = DateTime(2026, 9, 14);
  static final emptyWorkday = DateTime(2026, 9, 15);

  static final appointments = <DemoAppointment>[
    DemoAppointment(
      id: 'appointment_001',
      doctorId: DemoEmployees.doctor.id,
      patientId: 'patient_001',
      startsAt: DateTime(2026, 9, 14, 9),
      serviceTitle: 'Лечение зубов',
    ),
    DemoAppointment(
      id: 'appointment_002',
      doctorId: DemoEmployees.doctor.id,
      patientId: 'patient_002',
      startsAt: DateTime(2026, 9, 14, 11, 30),
      serviceTitle: 'Профессиональная гигиена',
    ),
    DemoAppointment(
      id: 'appointment_003',
      doctorId: DemoEmployees.doctor.id,
      patientId: 'patient_003',
      startsAt: DateTime(2026, 9, 14, 15),
      serviceTitle: 'Консультация',
    ),
  ];

  static List<DemoAppointment> appointmentsForDay(DateTime day) {
    return appointments
        .where((appointment) {
          final startsAt = appointment.startsAt;
          return startsAt.year == day.year &&
              startsAt.month == day.month &&
              startsAt.day == day.day;
        })
        .toList(growable: false);
  }
}
