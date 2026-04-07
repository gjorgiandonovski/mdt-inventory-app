import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Map<String, dynamic>?> getUser(String email) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_usersKey);
    if (raw == null) return null;
    final Map<String, dynamic> users = jsonDecode(raw);
    return users[email] as Map<String, dynamic>?;
  }

  Future<void> createUser(String email, String password, String role) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_usersKey);
    Map<String, dynamic> users = {};
    if (raw != null) {
      users = jsonDecode(raw);
    }
    users[email] = {
      'email': email,
      'password': password,
      'role': role,
      'uid': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final user = await getUser(email);
    if (user == null) return null;
    if (user['password'] != password) return null;

    final prefs = await _prefs;
    await prefs.setString(_currentUserKey, jsonEncode(user));
    return user;
  }

  Future<void> signOut() async {
    final prefs = await _prefs;
    await prefs.remove(_currentUserKey);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_currentUserKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<String> getRole(String uid) async {
    final user = await getCurrentUser();
    return user?['role'] ?? 'staff';
  }
}


