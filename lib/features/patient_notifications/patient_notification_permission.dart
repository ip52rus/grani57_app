import 'package:permission_handler/permission_handler.dart';

enum PatientNotificationPermissionStatus { enabled, disabled }

abstract interface class PatientNotificationPermissionGateway {
  Future<PatientNotificationPermissionStatus> status();

  Future<PatientNotificationPermissionStatus> request();

  Future<bool> openSystemSettings();
}

class DevicePatientNotificationPermissionGateway
    implements PatientNotificationPermissionGateway {
  const DevicePatientNotificationPermissionGateway();

  @override
  Future<PatientNotificationPermissionStatus> status() async =>
      _mapStatus(await Permission.notification.status);

  @override
  Future<PatientNotificationPermissionStatus> request() async =>
      _mapStatus(await Permission.notification.request());

  @override
  Future<bool> openSystemSettings() => openAppSettings();

  PatientNotificationPermissionStatus _mapStatus(PermissionStatus status) =>
      status.isGranted || status.isLimited || status.isProvisional
      ? PatientNotificationPermissionStatus.enabled
      : PatientNotificationPermissionStatus.disabled;
}
