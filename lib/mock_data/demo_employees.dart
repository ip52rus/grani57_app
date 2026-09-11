import '../core/mock_runtime/user_role.dart';
import 'demo_asset_paths.dart';
import 'demo_employee.dart';

abstract final class DemoEmployees {
  static const doctor = DemoEmployee(
    id: 'doctor_001',
    name: 'Анна Смирнова',
    role: UserRole.doctor,
    login: '+7 999 000-10-01',
    phone: '+7 999 000-10-01',
    password: 'Doctor57!',
    photoAsset: DemoAssetPaths.doctorAnnaSmirnova,
  );

  static const administrator = DemoEmployee(
    id: 'admin_001',
    name: 'Администратор 57 ГРАНЕЙ',
    role: UserRole.administrator,
    login: 'admin57',
    password: 'Grani57Demo!',
  );

  static const values = <DemoEmployee>[doctor, administrator];
}
