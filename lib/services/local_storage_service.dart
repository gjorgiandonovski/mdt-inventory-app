import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _devicesKey = 'devices';
  static const String _issuesKey = 'issues';
  static const String _usersKey = 'users';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> getDevices() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_devicesKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveDevices(List<Map<String, dynamic>> devices) async {
    final prefs = await _prefs;
    await prefs.setString(_devicesKey, jsonEncode(devices));
  }

  Future<void> saveDevice(Map<String, dynamic> device) async {
    final devices = await getDevices();
    final index = devices.indexWhere((d) => d['id'] == device['id']);
    if (index >= 0) {
      devices[index] = device;
    } else {
      devices.add(device);
    }
    await saveDevices(devices);
  }

  Future<void> deleteDevice(String id) async {
    final devices = await getDevices();
    devices.removeWhere((d) => d['id'] == id);
    await saveDevices(devices);
  }

  Future<List<Map<String, dynamic>>> getIssues() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_issuesKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveIssues(List<Map<String, dynamic>> issues) async {
    final prefs = await _prefs;
    await prefs.setString(_issuesKey, jsonEncode(issues));
  }

  Future<void> saveIssue(Map<String, dynamic> issue) async {
    final issues = await getIssues();
    if (issue['id'] == null || issue['id'] == '') {
      issue['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    final index = issues.indexWhere((i) => i['id'] == issue['id']);
    if (index >= 0) {
      issues[index] = issue;
    } else {
      issues.add(issue);
    }
    await saveIssues(issues);
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_usersKey);
    if (raw == null) return null;
    final Map<String, dynamic> users = jsonDecode(raw);
    return users[uid] as Map<String, dynamic>?;
  }

  Future<void> saveUser(String uid, Map<String, dynamic> userData) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_usersKey);
    Map<String, dynamic> users = {};
    if (raw != null) {
      users = jsonDecode(raw);
    }
    users[uid] = userData;
    await prefs.setString(_usersKey, jsonEncode(users));
  }
}


