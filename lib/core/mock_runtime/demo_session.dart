import 'user_role.dart';

class DemoSession {
  const DemoSession({
    required this.isAuthenticated,
    required this.userId,
    required this.role,
    this.phone,
    this.name,
  });

  const DemoSession.unauthenticated()
    : isAuthenticated = false,
      userId = null,
      role = null,
      phone = null,
      name = null;

  const DemoSession.authenticated({
    required String userId,
    required UserRole role,
    String? phone,
    String? name,
  }) : this(
         isAuthenticated: true,
         userId: userId,
         role: role,
         phone: phone,
         name: name,
       );

  final bool isAuthenticated;
  final String? userId;
  final UserRole? role;
  final String? phone;
  final String? name;

  bool get isValid => !isAuthenticated || (userId != null && role != null);
}
