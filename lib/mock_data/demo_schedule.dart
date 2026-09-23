import 'demo_appointment.dart';
import 'demo_employees.dart';

abstract final class DemoSchedule {
  static final selectedWorkday = DateTime(2026, 9, 14);
  static final emptyWorkday = DateTime(2026, 9, 15);

  static const clinic = 'Просвещения, 15';

  static final appointments = <DemoAppointment>[
    _appointment(
      id: 'appointment_001',
      patientId: 'doctor_patient_dmitry_sokolov',
      patientName: 'Дмитрий Соколов',
      day: 14,
      startHour: 9,
      durationMinutes: 60,
      service: 'Лечение зуба',
      status: 'Завершён',
      visitType: 'Повторный',
      comment: 'Плановый приём.',
    ),
    _appointment(
      id: 'appointment_002',
      patientId: 'doctor_patient_maria_petrova',
      patientName: 'Мария Петрова',
      day: 14,
      startHour: 10,
      startMinute: 30,
      durationMinutes: 30,
      service: 'Консультация стоматолога',
      status: 'Подтверждён',
      visitType: 'Повторный',
      comment: 'Плановая консультация. Вопросы\nпо дальнейшему лечению.',
    ),
    _appointment(
      id: 'appointment_003',
      patientId: 'doctor_patient_elena_kuznetsova',
      patientName: 'Елена Кузнецова',
      day: 14,
      startHour: 12,
      durationMinutes: 60,
      service: 'Профессиональная гигиена',
      status: 'Подтверждён',
      visitType: 'Первичный',
      comment: 'Плановый приём.',
    ),
    for (final day in const [2, 5, 8, 22, 28])
      _appointment(
        id: 'appointment_marker_$day',
        patientId: 'patient_001',
        patientName: 'Иван Петров',
        day: day,
        startHour: 10,
        durationMinutes: 30,
        service: 'Консультация стоматолога',
        status: 'Подтверждён',
        visitType: 'Повторный',
        comment: 'Плановый приём.',
      ),
  ];

  static DemoAppointment get featuredAppointment => appointments[1];

  static List<DemoAppointment> appointmentsForDay(
    DateTime day, {
    String doctorId = 'doctor_001',
  }) {
    return appointments
        .where(
          (appointment) =>
              appointment.doctorId == doctorId &&
              isSameDay(appointment.startsAt, day),
        )
        .toList(growable: false)
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  static bool hasAppointments(DateTime day, {String doctorId = 'doctor_001'}) =>
      appointments.any(
        (appointment) =>
            appointment.doctorId == doctorId &&
            isSameDay(appointment.startsAt, day),
      );

  static bool isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  static DemoAppointment _appointment({
    required String id,
    required String patientId,
    required String patientName,
    required int day,
    required int startHour,
    int startMinute = 0,
    required int durationMinutes,
    required String service,
    required String status,
    required String visitType,
    required String comment,
  }) {
    final startsAt = DateTime(2026, 9, day, startHour, startMinute);
    return DemoAppointment(
      id: id,
      doctorId: DemoEmployees.doctor.id,
      patientId: patientId,
      patientName: patientName,
      startsAt: startsAt,
      endsAt: startsAt.add(Duration(minutes: durationMinutes)),
      serviceTitle: service,
      statusLabel: status,
      clinic: clinic,
      cabinet: 'кабинет 3',
      visitType: visitType,
      comment: comment,
    );
  }
}
