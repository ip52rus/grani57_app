enum DemoPublicationType { news, promotion }

class DemoPublication {
  const DemoPublication({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.information,
    required this.clinic,
    required this.period,
    required this.isPublished,
    this.imageAsset,
  });

  final String id;
  final DemoPublicationType type;
  final String title;
  final String description;
  final String information;
  final String clinic;
  final String period;
  final bool isPublished;
  final String? imageAsset;

  DemoPublication copyWith({
    DemoPublicationType? type,
    String? title,
    String? description,
    String? information,
    String? clinic,
    String? period,
    bool? isPublished,
    String? imageAsset,
  }) => DemoPublication(
    id: id,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description ?? this.description,
    information: information ?? this.information,
    clinic: clinic ?? this.clinic,
    period: period ?? this.period,
    isPublished: isPublished ?? this.isPublished,
    imageAsset: imageAsset ?? this.imageAsset,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'information': information,
    'clinic': clinic,
    'period': period,
    'isPublished': isPublished,
    'imageAsset': imageAsset,
  };

  factory DemoPublication.fromJson(Map<String, Object?> json) {
    final typeName = json['type'] as String?;
    return DemoPublication(
      id: json['id'] as String,
      type: DemoPublicationType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => DemoPublicationType.news,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      information: json['information'] as String? ?? '',
      clinic: json['clinic'] as String? ?? '',
      period: json['period'] as String? ?? '',
      isPublished: json['isPublished'] as bool? ?? false,
      imageAsset: json['imageAsset'] as String?,
    );
  }
}

class DemoDoctorProfile {
  const DemoDoctorProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.services,
    this.photoAsset,
  });

  final String id;
  final String name;
  final String description;
  final List<String> services;
  final String? photoAsset;

  DemoDoctorProfile copyWith({
    String? name,
    String? description,
    List<String>? services,
    String? photoAsset,
  }) => DemoDoctorProfile(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    services: services ?? this.services,
    photoAsset: photoAsset ?? this.photoAsset,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'services': services,
    'photoAsset': photoAsset,
  };

  factory DemoDoctorProfile.fromJson(Map<String, Object?> json) =>
      DemoDoctorProfile(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        services: (json['services'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList(growable: false),
        photoAsset: json['photoAsset'] as String?,
      );
}

class DemoDoctorAccess {
  const DemoDoctorAccess({
    required this.doctorId,
    required this.login,
    required this.password,
    required this.isEnabled,
  });

  final String doctorId;
  final String login;
  final String password;
  final bool isEnabled;

  DemoDoctorAccess copyWith({
    String? login,
    String? password,
    bool? isEnabled,
  }) => DemoDoctorAccess(
    doctorId: doctorId,
    login: login ?? this.login,
    password: password ?? this.password,
    isEnabled: isEnabled ?? this.isEnabled,
  );

  Map<String, Object?> toJson() => {
    'doctorId': doctorId,
    'login': login,
    'password': password,
    'isEnabled': isEnabled,
  };

  factory DemoDoctorAccess.fromJson(Map<String, Object?> json) =>
      DemoDoctorAccess(
        doctorId: json['doctorId'] as String,
        login: json['login'] as String? ?? '',
        password: json['password'] as String? ?? '',
        isEnabled: json['isEnabled'] as bool? ?? true,
      );
}
