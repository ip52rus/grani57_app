class DemoPatientDocument {
  const DemoPatientDocument({
    required this.id,
    required this.title,
    required this.date,
    required this.listDetails,
    required this.doctor,
    required this.service,
    required this.performed,
    required this.recommendations,
    required this.nextVisit,
    required this.signedAt,
  });

  final String id;
  final String title;
  final DateTime date;
  final String listDetails;
  final String doctor;
  final String service;
  final String performed;
  final String recommendations;
  final String nextVisit;
  final DateTime signedAt;
}

abstract final class DemoPatientDocuments {
  static final items = <DemoPatientDocument>[
    DemoPatientDocument(
      id: 'conclusion_2026_08_22',
      title: 'Заключение врача',
      date: DateTime(2026, 8, 22),
      listDetails: 'Анна Смирнова\nПрофессиональная гигиена',
      doctor: 'Анна Смирнова',
      service: 'Профессиональная гигиена',
      performed: 'Осмотр и профессиональная гигиена полости рта.',
      recommendations:
          'Индивидуальные рекомендации по уходу доступны в приложенном '
          'документе.',
      nextVisit: 'В срок, согласованный с врачом.',
      signedAt: DateTime(2026, 8, 22, 14, 10),
    ),
    DemoPatientDocument(
      id: 'recommendations_2026_08_22',
      title: 'Рекомендации после приёма',
      date: DateTime(2026, 8, 22),
      listDetails: 'PDF, 240 КБ',
      doctor: 'Анна Смирнова',
      service: 'Профессиональная гигиена',
      performed: 'Осмотр и профессиональная гигиена полости рта.',
      recommendations:
          'Индивидуальные рекомендации по уходу доступны в приложенном '
          'документе.',
      nextVisit: 'В срок, согласованный с врачом.',
      signedAt: DateTime(2026, 8, 22, 14, 10),
    ),
    DemoPatientDocument(
      id: 'conclusion_2026_06_18',
      title: 'Заключение врача',
      date: DateTime(2026, 6, 18),
      listDetails: 'Анна Смирнова\nПервичная консультация',
      doctor: 'Анна Смирнова',
      service: 'Первичная консультация',
      performed: 'Осмотр и консультация стоматолога.',
      recommendations:
          'Индивидуальные рекомендации по уходу доступны в приложенном '
          'документе.',
      nextVisit: 'В срок, согласованный с врачом.',
      signedAt: DateTime(2026, 6, 18, 16, 40),
    ),
  ];

  static DemoPatientDocument forDate(DateTime date) => items.firstWhere(
    (document) =>
        document.date.year == date.year &&
        document.date.month == date.month &&
        document.date.day == date.day,
    orElse: () => items.first,
  );
}
