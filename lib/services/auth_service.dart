import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static const String _userKey = 'khisab_user';

  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null || userStr.isEmpty) return null;
    try {
      final json = jsonDecode(userStr);
      return AppUser.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await ApiService.login(email: email, password: password);
    if (result['success'] == true) {
      final userData = result['data']['user'];
      final user = AppUser.fromJson(userData);
      await saveUser(user);
      return {'success': true, 'user': user};
    }
    return result;
  }

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final result = await ApiService.signup(
      username: username,
      email: email,
      password: password,
    );
    if (result['success'] == true) {
      final userData = result['data']['user'];
      final user = AppUser.fromJson(userData);
      await saveUser(user);
      return {'success': true, 'user': user};
    }
    return result;
  }
}
