import 'package:shared_preferences/shared_preferences.dart';

class PatientNotificationPreferences {
  const PatientNotificationPreferences({
    this.appointments = true,
    this.documents = true,
    this.news = false,
  });

  final bool appointments;
  final bool documents;
  final bool news;

  PatientNotificationPreferences copyWith({
    bool? appointments,
    bool? documents,
    bool? news,
  }) => PatientNotificationPreferences(
    appointments: appointments ?? this.appointments,
    documents: documents ?? this.documents,
    news: news ?? this.news,
  );
}

class PatientNotificationStore {
  PatientNotificationStore([this._preferences]);

  final SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async =>
      _preferences ?? SharedPreferences.getInstance();

  String _key(String patientId, String suffix) =>
      'patient_notifications.$patientId.$suffix';

  Future<PatientNotificationPreferences> loadPreferences(
    String patientId,
  ) async {
    final prefs = await _prefs();
    return PatientNotificationPreferences(
      appointments: prefs.getBool(_key(patientId, 'appointments')) ?? true,
      documents: prefs.getBool(_key(patientId, 'documents')) ?? true,
      news: prefs.getBool(_key(patientId, 'news')) ?? false,
    );
  }

  Future<void> savePreferences(
    String patientId,
    PatientNotificationPreferences value,
  ) async {
    final prefs = await _prefs();
    await Future.wait([
      prefs.setBool(_key(patientId, 'appointments'), value.appointments),
      prefs.setBool(_key(patientId, 'documents'), value.documents),
      prefs.setBool(_key(patientId, 'news'), value.news),
    ]);
  }

  Future<bool> wasPermissionRequested(String patientId) async =>
      (await _prefs()).getBool(_key(patientId, 'permission_requested')) ??
      false;

  Future<void> markPermissionRequested(String patientId) async {
    await (await _prefs()).setBool(
      _key(patientId, 'permission_requested'),
      true,
    );
  }

  Future<Set<String>> readIds(String patientId) async =>
      ((await _prefs()).getStringList(_key(patientId, 'read_ids')) ?? const [])
          .toSet();

  Future<void> markRead(String patientId, String notificationId) async {
    final prefs = await _prefs();
    final ids =
        (prefs.getStringList(_key(patientId, 'read_ids')) ?? const []).toSet()
          ..add(notificationId);
    await prefs.setStringList(_key(patientId, 'read_ids'), ids.toList());
  }
}
