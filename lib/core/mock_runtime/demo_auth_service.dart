import '../../mock_data/demo_employee.dart';
import '../../mock_data/demo_employees.dart';
import '../../mock_data/demo_patient.dart';
import '../../mock_data/demo_patients.dart';
import 'demo_session.dart';
import 'user_role.dart';

class DemoPatientLookupResult {
  const DemoPatientLookupResult.registered({
    required this.normalizedPhone,
    required this.patient,
  }) : isRegistered = true;

  const DemoPatientLookupResult.newPatient({required this.normalizedPhone})
    : isRegistered = false,
      patient = null;

  final String normalizedPhone;
  final bool isRegistered;
  final DemoPatient? patient;
}

class DemoAuthService {
  DemoAuthService({List<DemoPatient>? patients, List<DemoEmployee>? employees})
    : _patients = patients ?? DemoPatients.values,
      _employees = employees ?? DemoEmployees.values;

  final List<DemoPatient> _patients;
  final List<DemoEmployee> _employees;

  DemoPatientLookupResult lookupPatientByPhone(String rawPhone) {
    final normalizedPhone = normalizeRussianPhone(rawPhone);
    final patient = _patientByNormalizedPhone(normalizedPhone);
    if (patient == null) {
      return DemoPatientLookupResult.newPatient(
        normalizedPhone: normalizedPhone,
      );
    }

    return DemoPatientLookupResult.registered(
      normalizedPhone: normalizedPhone,
      patient: patient,
    );
  }

  bool validatePatientSms({required String rawPhone, required String smsCode}) {
    final patient = _patientByNormalizedPhone(normalizeRussianPhone(rawPhone));
    return patient != null && patient.smsCode == smsCode.trim();
  }

  DemoSession? authenticateRegisteredPatient({
    required String rawPhone,
    required String smsCode,
  }) {
    final lookup = lookupPatientByPhone(rawPhone);
    final patient = lookup.patient;
    if (patient == null ||
        !validatePatientSms(rawPhone: rawPhone, smsCode: smsCode)) {
      return null;
    }

    return DemoSession.authenticated(
      userId: patient.id,
      role: UserRole.patient,
    );
  }

  DemoSession? authenticateEmployee({
    required String login,
    required String password,
  }) {
    final normalizedLogin = _normalizeEmployeeLogin(login);
    for (final employee in _employees) {
      final candidateLogin = _normalizeEmployeeLogin(employee.login);
      final candidatePhone = employee.phone == null
          ? null
          : _normalizeEmployeeLogin(employee.phone!);
      final loginMatches =
          candidateLogin == normalizedLogin ||
          candidatePhone == normalizedLogin;
      if (loginMatches && employee.password == password) {
        return DemoSession.authenticated(
          userId: employee.id,
          role: employee.role,
        );
      }
    }
    return null;
  }

  DemoPatient? _patientByNormalizedPhone(String normalizedPhone) {
    for (final patient in _patients) {
      if (normalizeRussianPhone(patient.phone) == normalizedPhone) {
        return patient;
      }
    }
    return null;
  }

  String _normalizeEmployeeLogin(String value) {
    final trimmed = value.trim();
    if (trimmed.contains(RegExp(r'\d'))) {
      return normalizeRussianPhone(trimmed);
    }
    return trimmed.toLowerCase();
  }
}

String normalizeRussianPhone(String rawPhone) {
  final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('8')) {
    return '7${digits.substring(1)}';
  }
  if (digits.length == 11 && digits.startsWith('7')) {
    return digits;
  }
  if (digits.length == 10) {
    return '7$digits';
  }
  return digits;
}
