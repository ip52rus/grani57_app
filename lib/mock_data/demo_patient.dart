class DemoPatient {
  const DemoPatient({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.phone,
    required this.smsCode,
    required this.acceptedConsentVersion,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final String phone;

  // Demo-only local verification code. Never use this pattern in production.
  final String smsCode;
  final String acceptedConsentVersion;
}

class PendingDemoPatientRegistration {
  const PendingDemoPatientRegistration({
    required this.normalizedPhone,
    required this.smsVerified,
    this.acceptedConsentVersion,
  });

  final String normalizedPhone;
  final bool smsVerified;
  final String? acceptedConsentVersion;
}
