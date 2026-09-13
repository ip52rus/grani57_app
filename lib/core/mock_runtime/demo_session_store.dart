import 'package:shared_preferences/shared_preferences.dart';

import 'demo_session.dart';
import 'user_role.dart';

class DemoSessionStore {
  DemoSessionStore({this.preferences});

  static const _isAuthenticatedKey = 'demo_session.is_authenticated';
  static const _userIdKey = 'demo_session.user_id';
  static const _roleKey = 'demo_session.role';

  final SharedPreferences? preferences;

  Future<DemoSession> restoreSession() async {
    try {
      final preferences = await _getPreferences();
      final isAuthenticated = preferences.getBool(_isAuthenticatedKey) ?? false;
      if (!isAuthenticated) {
        return const DemoSession.unauthenticated();
      }

      final userId = preferences.getString(_userIdKey);
      final role = _parseRole(preferences.getString(_roleKey));
      if (userId == null || role == null) {
        await clearSession();
        return const DemoSession.unauthenticated();
      }

      return DemoSession.authenticated(userId: userId, role: role);
    } catch (_) {
      await clearSession();
      return const DemoSession.unauthenticated();
    }
  }

  Future<void> saveSession(DemoSession session) async {
    final preferences = await _getPreferences();
    if (!session.isAuthenticated) {
      await clearSession();
      return;
    }

    final userId = session.userId;
    final role = session.role;
    if (userId == null || role == null) {
      throw ArgumentError(
        'Authenticated demo session requires userId and role.',
      );
    }

    await preferences.setBool(_isAuthenticatedKey, true);
    await preferences.setString(_userIdKey, userId);
    await preferences.setString(_roleKey, role.name);
  }

  Future<void> clearSession() async {
    final preferences = await _getPreferences();
    await preferences.remove(_isAuthenticatedKey);
    await preferences.remove(_userIdKey);
    await preferences.remove(_roleKey);
  }

  Future<SharedPreferences> _getPreferences() async {
    final injectedPreferences = preferences;
    if (injectedPreferences != null) {
      return injectedPreferences;
    }
    return SharedPreferences.getInstance();
  }

  UserRole? _parseRole(String? value) {
    if (value == null) {
      return null;
    }

    for (final role in UserRole.values) {
      if (role.name == value) {
        return role;
      }
    }
    return null;
  }
}
