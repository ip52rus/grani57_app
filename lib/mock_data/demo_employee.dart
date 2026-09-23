import '../core/mock_runtime/user_role.dart';

class DemoEmployee {
  const DemoEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.login,
    required this.password,
    this.username,
    this.phone,
    this.photoAsset,
  });

  final String id;
  final String name;
  final UserRole role;
  final String login;
  final String? username;

  // Demo-only fixture credential. Never store production passwords this way.
  final String password;
  final String? phone;
  final String? photoAsset;
}
