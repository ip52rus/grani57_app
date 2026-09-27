import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mock_data/demo_admin_models.dart';

class DoctorAccessStore extends ChangeNotifier {
  DoctorAccessStore({this.preferences});

  static const _storageKey = 'admin_demo.doctor_access.v1';
  final SharedPreferences? preferences;
  final List<DemoDoctorAccess> _access = [];
  bool _initialized = false;

  List<DemoDoctorAccess> get values => List.unmodifiable(_access);

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final raw = (await _preferences()).getString(_storageKey);
      _access
        ..clear()
        ..addAll(_decode(raw));
    } on MissingPluginException {
      _access
        ..clear()
        ..addAll(seedAccess);
    }
    _initialized = true;
  }

  DemoDoctorAccess? accessForDoctor(String doctorId) {
    for (final access in _access) {
      if (access.doctorId == doctorId) return access;
    }
    return null;
  }

  Future<DemoDoctorAccess?> authenticate({
    required String login,
    required String password,
  }) async {
    await initialize();
    final normalized = login.trim().toLowerCase();
    for (final access in _access) {
      if (access.isEnabled &&
          access.login.trim().toLowerCase() == normalized &&
          access.password == password) {
        return access;
      }
    }
    return null;
  }

  Future<void> save(DemoDoctorAccess access) async {
    await initialize();
    final duplicate = _access.any(
      (item) =>
          item.doctorId != access.doctorId &&
          item.login.trim().toLowerCase() == access.login.trim().toLowerCase(),
    );
    if (duplicate) throw ArgumentError('Этот логин уже используется');
    final index = _access.indexWhere(
      (item) => item.doctorId == access.doctorId,
    );
    if (index == -1) {
      _access.add(access);
    } else {
      _access[index] = access;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setEnabled(String doctorId, bool enabled) async {
    await initialize();
    final access = accessForDoctor(doctorId);
    if (access == null) return;
    await save(access.copyWith(isEnabled: enabled));
  }

  Future<void> remove(String doctorId) async {
    await initialize();
    _access.removeWhere((item) => item.doctorId == doctorId);
    await _persist();
    notifyListeners();
  }

  List<DemoDoctorAccess> _decode(String? raw) {
    if (raw == null) return List.of(seedAccess);
    try {
      return (jsonDecode(raw) as List<Object?>)
          .whereType<Map<String, Object?>>()
          .map(DemoDoctorAccess.fromJson)
          .toList();
    } catch (_) {
      return List.of(seedAccess);
    }
  }

  Future<void> _persist() async {
    await (await _preferences()).setString(
      _storageKey,
      jsonEncode(_access.map((item) => item.toJson()).toList()),
    );
  }

  Future<SharedPreferences> _preferences() async =>
      preferences ?? SharedPreferences.getInstance();

  static const seedAccess = <DemoDoctorAccess>[
    DemoDoctorAccess(
      doctorId: 'doctor_001',
      login: 'anna.smirnova',
      password: 'Doctor57!',
      isEnabled: true,
    ),
  ];
}
