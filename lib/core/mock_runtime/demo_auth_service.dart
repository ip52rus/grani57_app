import '../../mock_data/demo_employee.dart';
import '../../mock_data/demo_employees.dart';
import '../../mock_data/demo_patient.dart';
import '../../mock_data/demo_patients.dart';
import 'admin_demo_store.dart';
import 'demo_session.dart';
import 'doctor_access_store.dart';
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
  DemoAuthService({
    List<DemoPatient>? patients,
    List<DemoEmployee>? employees,
    AdminDemoStore? adminStore,
    DoctorAccessStore? doctorAccessStore,
  }) : _patients = patients ?? DemoPatients.values,
       _employees = employees ?? DemoEmployees.values,
       adminStore = adminStore ?? AdminDemoStore(),
       doctorAccessStore = doctorAccessStore ?? DoctorAccessStore();

  final List<DemoPatient> _patients;
  final List<DemoEmployee> _employees;
  final AdminDemoStore adminStore;
  final DoctorAccessStore doctorAccessStore;

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
      phone: formatRussianPhoneForDisplay(rawPhone),
      name: patient.name,
    );
  }

  bool validateNewPatientSms(String smsCode) => smsCode.trim() == '111111';

  DemoSession createNewPatientSession({
    required String rawPhone,
    required String name,
  }) {
    final normalizedPhone = normalizeRussianPhone(rawPhone);
    return DemoSession.authenticated(
      userId: 'new_patient_$normalizedPhone',
      role: UserRole.patient,
      phone: formatRussianPhoneForDisplay(rawPhone),
      name: name,
    );
  }

  Future<DemoSession?> authenticateEmployee({
    required String login,
    required String password,
  }) async {
    final normalizedLogin = _normalizeEmployeeLogin(login);
    for (final employee in _employees.where(
      (employee) => employee.role == UserRole.administrator,
    )) {
      final candidateLogin = _normalizeEmployeeLogin(employee.login);
      final candidatePhone = employee.phone == null
          ? null
          : _normalizeEmployeeLogin(employee.phone!);
      final candidateUsername = employee.username == null
          ? null
          : _normalizeEmployeeLogin(employee.username!);
      final loginMatches =
          candidateLogin == normalizedLogin ||
          candidatePhone == normalizedLogin ||
          candidateUsername == normalizedLogin;
      if (loginMatches && employee.password == password) {
        return DemoSession.authenticated(
          userId: employee.id,
          role: employee.role,
          name: employee.name,
        );
      }
    }

    await adminStore.initialize();
    await doctorAccessStore.initialize();
    var access = await doctorAccessStore.authenticate(
      login: login,
      password: password,
    );

    // Keep the originally shipped doctor phone credential compatible until
    // the administrator changes that doctor's access record.
    final seeded = doctorAccessStore.accessForDoctor(DemoEmployees.doctor.id);
    if (access == null &&
        seeded?.login == DemoEmployees.doctor.username &&
        seeded?.password == DemoEmployees.doctor.password &&
        seeded?.isEnabled == true &&
        normalizedLogin ==
            _normalizeEmployeeLogin(DemoEmployees.doctor.phone ?? '') &&
        password == DemoEmployees.doctor.password) {
      access = seeded;
    }

    if (access == null) return null;
    final doctor = adminStore.doctorById(access.doctorId);
    if (doctor == null) return null;
    return DemoSession.authenticated(
      userId: doctor.id,
      role: UserRole.doctor,
      name: doctor.name,
    );
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

String formatRussianPhoneForDisplay(String rawPhone) {
  final normalizedPhone = normalizeRussianPhone(rawPhone);
  if (normalizedPhone.length != 11 || !normalizedPhone.startsWith('7')) {
    return rawPhone.trim();
  }

  return '+7 (${normalizedPhone.substring(1, 4)}) '
      '${normalizedPhone.substring(4, 7)}-${normalizedPhone.substring(7, 9)}-'
      '${normalizedPhone.substring(9, 11)}';
}
