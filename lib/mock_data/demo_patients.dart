import 'demo_patient.dart';

abstract final class DemoConsent {
  static const currentConsentVersion = 'demo-consent-v1';
}

abstract final class DemoPatients {
  static final values = <DemoPatient>[
    DemoPatient(
      id: 'patient_001',
      name: 'Иван Петров',
      birthDate: DateTime(1988, 3, 14),
      phone: '+7 999 000-00-01',
      smsCode: '111111',
      acceptedConsentVersion: DemoConsent.currentConsentVersion,
    ),
    DemoPatient(
      id: 'patient_002',
      name: 'Мария Соколова',
      birthDate: DateTime(1994, 7, 27),
      phone: '+7 999 000-00-02',
      smsCode: '222222',
      acceptedConsentVersion: DemoConsent.currentConsentVersion,
    ),
    DemoPatient(
      id: 'patient_003',
      name: 'Алексей Орлов',
      birthDate: DateTime(1981, 11, 5),
      phone: '+7 999 000-00-03',
      smsCode: '333333',
      acceptedConsentVersion: DemoConsent.currentConsentVersion,
    ),
  ];
}
