import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kitab.dart';

class ApiService {
  static const String defaultBaseUrl = 'https://machine-khisab-kitab.vercel.app';
  static const String _prefServerUrlKey = 'custom_backend_url';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString(_prefServerUrlKey);
    // Automatically ignore any legacy localhost or loopback URLs
    if (custom != null &&
        custom.isNotEmpty &&
        !custom.contains('localhost') &&
        !custom.contains('127.0.0.1') &&
        !custom.contains('10.0.2.2')) {
      return custom;
    }
    return defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    String cleaned = url.trim();
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    await prefs.setString(_prefServerUrlKey, cleaned);
  }

  static Future<bool> checkHealth() async {
    try {
      final baseUrl = await getBaseUrl();
      final res = await http.get(Uri.parse('$baseUrl/')).timeout(const Duration(seconds: 5));
      return res.statusCode >= 200 && res.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  // --- Auth APIs ---
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: Unable to reach server. Please check your internet connection.'};
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Sign up failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: Unable to reach server. Please check your internet connection.'};
    }
  }

  // --- Kitabs APIs (Direct Cloud MongoDB) ---
  static Future<List<Kitab>> getKitabs({required String userId}) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/kitabs'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => Kitab.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Kitab?> getKitab({
    required String kitabId,
    required String userId,
  }) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/kitabs/$kitabId'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Kitab.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  static Future<Kitab?> createKitab({
    required Kitab kitab,
    required String userId,
  }) async {
    Kitab toSave = kitab;
    if (toSave.id.isEmpty) {
      toSave = Kitab(
        id: 'kitab_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        username: toSave.username,
        title: toSave.title,
        number: toSave.number,
        startDate: toSave.startDate,
        endDate: toSave.endDate,
        days: toSave.days,
        completed: toSave.completed,
        createdAt: toSave.createdAt,
        spendMoney: toSave.spendMoney,
        handOver: toSave.handOver,
        iHave: toSave.iHave,
        moneyLeft: toSave.moneyLeft,
        masara: toSave.masara,
        moneySaved: toSave.moneySaved,
      );
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/kitabs'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
        body: jsonEncode(toSave.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Kitab.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    return null;
  }

  static Future<Kitab?> updateKitab({
    required Kitab kitab,
    required String userId,
  }) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/kitabs/${kitab.id}'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
        body: jsonEncode(kitab.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Kitab.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    return null;
  }

  static Future<bool> deleteKitab({
    required String kitabId,
    required String userId,
  }) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/kitabs/$kitabId'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
