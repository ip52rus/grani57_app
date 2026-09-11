import 'user_role.dart';

class DemoSession {
  const DemoSession({
    required this.isAuthenticated,
    required this.userId,
    required this.role,
  });

  const DemoSession.unauthenticated()
    : isAuthenticated = false,
      userId = null,
      role = null;

  const DemoSession.authenticated({
    required String userId,
    required UserRole role,
  }) : this(isAuthenticated: true, userId: userId, role: role);

  final bool isAuthenticated;
  final String? userId;
  final UserRole? role;

  bool get isValid => !isAuthenticated || (userId != null && role != null);
}
