enum PatientNotificationKind { appointment, document, news }

class DemoPatientNotification {
  const DemoPatientNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isNew = false,
  });

  final String id;
  final PatientNotificationKind kind;
  final String title;
  final String body;
  final String timestamp;
  final bool isNew;
}

abstract final class DemoPatientNotifications {
  static const _items = <DemoPatientNotification>[
    DemoPatientNotification(
      id: 'appointment_2026_09_14',
      kind: PatientNotificationKind.appointment,
      title: 'Вы записаны на приём',
      body: '14 сентября в 10:30. Детали записи доступны в приложении.',
      timestamp: '10:32',
      isNew: true,
    ),
    DemoPatientNotification(
      id: 'document_2026_08_22',
      kind: PatientNotificationKind.document,
      title: 'Ваш документ готов',
      body: 'Заключение врача уже в разделе «Документы».',
      timestamp: '22 августа · 14:10',
    ),
    DemoPatientNotification(
      id: 'news_new_clinic',
      kind: PatientNotificationKind.news,
      title: 'Скоро — новая клиника',
      body: '«57 граней» на Большеохтинском проспекте.',
      timestamp: '20 августа · 12:00',
    ),
  ];

  static List<DemoPatientNotification> forPatient(String? patientId) =>
      patientId == 'patient_001' ? _items : const [];
}
