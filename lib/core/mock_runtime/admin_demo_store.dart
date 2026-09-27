import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mock_data/demo_admin_models.dart';

class AdminDemoStore extends ChangeNotifier {
  AdminDemoStore({this.preferences});

  static const _publicationsKey = 'admin_demo.publications.v1';
  static const _doctorsKey = 'admin_demo.doctors.v1';

  final SharedPreferences? preferences;
  final List<DemoPublication> _publications = [];
  final List<DemoDoctorProfile> _doctors = [];
  bool _initialized = false;

  List<DemoPublication> get publications => List.unmodifiable(_publications);
  List<DemoDoctorProfile> get doctors => List.unmodifiable(_doctors);
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await _preferences();
      _publications
        ..clear()
        ..addAll(_decodePublications(prefs.getString(_publicationsKey)));
      _doctors
        ..clear()
        ..addAll(_decodeDoctors(prefs.getString(_doctorsKey)));
    } on MissingPluginException {
      _publications
        ..clear()
        ..addAll(seedPublications);
      _doctors
        ..clear()
        ..addAll(seedDoctors);
    }
    _initialized = true;
  }

  DemoDoctorProfile? doctorById(String doctorId) {
    for (final doctor in _doctors) {
      if (doctor.id == doctorId) return doctor;
    }
    return null;
  }

  Future<void> savePublication(DemoPublication publication) async {
    await initialize();
    final index = _publications.indexWhere((item) => item.id == publication.id);
    if (index == -1) {
      _publications.insert(0, publication);
    } else {
      _publications[index] = publication;
    }
    await _persistPublications();
    notifyListeners();
  }

  Future<void> deletePublication(String id) async {
    await initialize();
    _publications.removeWhere((item) => item.id == id);
    await _persistPublications();
    notifyListeners();
  }

  Future<void> saveDoctor(DemoDoctorProfile doctor) async {
    await initialize();
    final index = _doctors.indexWhere((item) => item.id == doctor.id);
    if (index == -1) {
      _doctors.add(doctor);
    } else {
      _doctors[index] = doctor;
    }
    await _persistDoctors();
    notifyListeners();
  }

  Future<void> deleteDoctor(String id) async {
    await initialize();
    _doctors.removeWhere((item) => item.id == id);
    await _persistDoctors();
    notifyListeners();
  }

  Future<SharedPreferences> _preferences() async =>
      preferences ?? SharedPreferences.getInstance();

  List<DemoPublication> _decodePublications(String? raw) {
    if (raw == null) return List.of(seedPublications);
    try {
      return (jsonDecode(raw) as List<Object?>)
          .whereType<Map<String, Object?>>()
          .map(DemoPublication.fromJson)
          .toList();
    } catch (_) {
      return List.of(seedPublications);
    }
  }

  List<DemoDoctorProfile> _decodeDoctors(String? raw) {
    if (raw == null) return List.of(seedDoctors);
    try {
      return (jsonDecode(raw) as List<Object?>)
          .whereType<Map<String, Object?>>()
          .map(DemoDoctorProfile.fromJson)
          .toList();
    } catch (_) {
      return List.of(seedDoctors);
    }
  }

  Future<void> _persistPublications() async {
    final value = jsonEncode(
      _publications.map((item) => item.toJson()).toList(),
    );
    await (await _preferences()).setString(_publicationsKey, value);
  }

  Future<void> _persistDoctors() async {
    final value = jsonEncode(_doctors.map((item) => item.toJson()).toList());
    await (await _preferences()).setString(_doctorsKey, value);
  }

  static const seedPublications = <DemoPublication>[
    DemoPublication(
      id: 'publication_001',
      type: DemoPublicationType.promotion,
      title: 'Сияйте изнутри',
      description: 'Знакомство с клиникой',
      information: 'Специальное предложение для пациентов клиники.',
      clinic: 'Все клиники',
      period: '10–30 сентября 2026',
      isPublished: true,
      imageAsset: 'assets/images/publications/news_glass_graphic.png',
    ),
    DemoPublication(
      id: 'publication_002',
      type: DemoPublicationType.news,
      title: 'Скоро на Охте',
      description: 'Новый филиал 57 ГРАНЕЙ',
      information: 'Следите за новостями об открытии.',
      clinic: 'Большеохтинский',
      period: 'с 10 сентября 2026',
      isPublished: true,
    ),
    DemoPublication(
      id: 'publication_003',
      type: DemoPublicationType.news,
      title: 'Как подготовиться к визиту',
      description: 'Памятка для пациента',
      information: 'Возьмите документы и приходите за 10 минут до приёма.',
      clinic: 'Все клиники',
      period: 'Черновик',
      isPublished: false,
    ),
  ];

  static const seedDoctors = <DemoDoctorProfile>[
    DemoDoctorProfile(
      id: 'doctor_001',
      name: 'Анна Смирнова',
      description:
          'Стоматолог-терапевт · стаж 12 лет. Кандидат медицинских наук.',
      services: ['Лечение зубов', 'Консультация стоматолога'],
      photoAsset: 'assets/images/doctors/doctor_anna_smirnova.png',
    ),
    DemoDoctorProfile(
      id: 'doctor_002',
      name: 'Алексей Волков',
      description: 'Стоматолог-хирург · стаж 9 лет',
      services: ['Хирургия', 'Имплантация', 'Консультация стоматолога'],
      photoAsset: 'assets/images/doctors/doctor_alexey_volkov.png',
    ),
    DemoDoctorProfile(
      id: 'doctor_003',
      name: 'Елена Кузнецова',
      description: 'Стоматолог-гигиенист · стаж 8 лет',
      services: ['Профессиональная гигиена', 'Отбеливание'],
      photoAsset: 'assets/images/doctors/doctor_elena_kuznetsova.png',
    ),
  ];
}
