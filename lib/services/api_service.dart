import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kitab.dart';

class ApiService {
  static const String defaultBaseUrl = 'http://localhost:5000';
  static const String _prefServerUrlKey = 'custom_backend_url';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefServerUrlKey) ?? defaultBaseUrl;
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
      final res = await http.get(Uri.parse('$baseUrl/')).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
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
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot reach server at $baseUrl: $e'};
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
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Sign up failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot reach server at $baseUrl: $e'};
    }
  }

  // --- Local Offline Cache & Sync Queue ---
  static String _offlineKitabsKey(String userId) => 'offline_kitabs_$userId';
  static String _pendingSyncKey(String userId) => 'pending_sync_kitabs_$userId';
  static String _pendingDeleteKey(String userId) => 'pending_delete_kitabs_$userId';

  static Future<List<Kitab>> getLocalKitabs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_offlineKitabsKey(userId));
      if (str == null || str.isEmpty) return [];
      final List<dynamic> list = jsonDecode(str);
      return list.map((item) => Kitab.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLocalKitabs(String userId, List<Kitab> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(list.map((k) => k.toJson()).toList());
      await prefs.setString(_offlineKitabsKey(userId), jsonStr);
    } catch (_) {}
  }

  static Future<Set<String>> _getPendingSyncIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingSyncKey(userId)) ?? [];
    return list.toSet();
  }

  static Future<void> _addPendingSyncId(String userId, String kitabId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_pendingSyncKey(userId)) ?? []).toSet();
    set.add(kitabId);
    await prefs.setStringList(_pendingSyncKey(userId), set.toList());
  }

  static Future<void> _removePendingSyncId(String userId, String kitabId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_pendingSyncKey(userId)) ?? []).toSet();
    set.remove(kitabId);
    await prefs.setStringList(_pendingSyncKey(userId), set.toList());
  }

  static Future<Set<String>> _getPendingDeleteIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingDeleteKey(userId)) ?? [];
    return list.toSet();
  }

  static Future<void> _addPendingDeleteId(String userId, String kitabId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_pendingDeleteKey(userId)) ?? []).toSet();
    set.add(kitabId);
    await prefs.setStringList(_pendingDeleteKey(userId), set.toList());
  }

  static Future<void> _removePendingDeleteId(String userId, String kitabId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_pendingDeleteKey(userId)) ?? []).toSet();
    set.remove(kitabId);
    await prefs.setStringList(_pendingDeleteKey(userId), set.toList());
  }

  // Check how many items are waiting to be uploaded to MongoDB
  static Future<int> getPendingSyncCount(String userId) async {
    final syncs = await _getPendingSyncIds(userId);
    final dels = await _getPendingDeleteIds(userId);
    return syncs.length + dels.length;
  }

  // --- Two-Way Automatic Sync with MongoDB ---
  static Future<Map<String, dynamic>> syncWithMongoDB(String userId) async {
    final baseUrl = await getBaseUrl();
    int syncedCount = 0;

    try {
      final isOnline = await checkHealth();
      if (!isOnline) {
        return {'success': false, 'message': 'Backend server unreachable.'};
      }

      // 1. Process pending deletes
      final pendingDeletes = await _getPendingDeleteIds(userId);
      for (final delId in pendingDeletes) {
        try {
          await http.delete(
            Uri.parse('$baseUrl/api/kitabs/$delId'),
            headers: {'Content-Type': 'application/json', 'x-user-id': userId},
          ).timeout(const Duration(seconds: 4));
          await _removePendingDeleteId(userId, delId);
          syncedCount++;
        } catch (_) {}
      }

      // 2. Process pending updates and creations
      final pendingSyncs = await _getPendingSyncIds(userId);
      final localKitabs = await getLocalKitabs(userId);

      for (final syncId in pendingSyncs) {
        final kitab = localKitabs.where((k) => k.id == syncId).firstOrNull;
        if (kitab == null) {
          await _removePendingSyncId(userId, syncId);
          continue;
        }

        try {
          // Try update first (if it already exists in MongoDB)
          final putRes = await http.put(
            Uri.parse('$baseUrl/api/kitabs/${kitab.id}'),
            headers: {'Content-Type': 'application/json', 'x-user-id': userId},
            body: jsonEncode(kitab.toJson()),
          ).timeout(const Duration(seconds: 4));

          if (putRes.statusCode == 200) {
            await _removePendingSyncId(userId, syncId);
            syncedCount++;
          } else if (putRes.statusCode == 404) {
            // Kitab was created offline and does not exist in MongoDB yet: POST it!
            final postRes = await http.post(
              Uri.parse('$baseUrl/api/kitabs'),
              headers: {'Content-Type': 'application/json', 'x-user-id': userId},
              body: jsonEncode(kitab.toJson()),
            ).timeout(const Duration(seconds: 4));

            if (postRes.statusCode == 200 || postRes.statusCode == 201) {
              await _removePendingSyncId(userId, syncId);
              syncedCount++;
            }
          }
        } catch (_) {}
      }

      // 3. Fetch latest database state and update local cache
      final getRes = await http.get(
        Uri.parse('$baseUrl/api/kitabs'),
        headers: {'Content-Type': 'application/json', 'x-user-id': userId},
      ).timeout(const Duration(seconds: 4));

      if (getRes.statusCode == 200) {
        final List<dynamic> list = jsonDecode(getRes.body);
        final serverList = list.map((item) => Kitab.fromJson(item)).toList();
        await saveLocalKitabs(userId, serverList);
      }

      return {'success': true, 'syncedCount': syncedCount};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // --- Kitabs APIs (Local-First Offline Resilient) ---
  static Future<List<Kitab>> getKitabs({required String userId}) async {
    final localList = await getLocalKitabs(userId);

    // If online, run background sync and fetch latest
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/kitabs'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        final serverList = list.map((item) => Kitab.fromJson(item)).toList();

        // Also push any pending offline changes if any
        final pending = await getPendingSyncCount(userId);
        if (pending > 0) {
          syncWithMongoDB(userId);
        } else {
          await saveLocalKitabs(userId, serverList);
        }

        return serverList;
      }
    } catch (_) {
      // Offline or server unreachable: return local cache immediately
    }

    return localList;
  }

  static Future<Kitab?> getKitab({
    required String kitabId,
    required String userId,
  }) async {
    final localList = await getLocalKitabs(userId);
    final localMatch = localList.where((k) => k.id == kitabId).firstOrNull;

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/kitabs/$kitabId'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return Kitab.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    return localMatch;
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

    // 1. Save to local storage first
    final localList = await getLocalKitabs(userId);
    localList.insert(0, toSave);
    await saveLocalKitabs(userId, localList);

    // 2. Mark as pending sync in case offline
    await _addPendingSyncId(userId, toSave.id);

    // 3. Try posting to MongoDB
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/kitabs'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
        body: jsonEncode(toSave.toJson()),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success: remove from pending sync
        await _removePendingSyncId(userId, toSave.id);
        final serverKitab = Kitab.fromJson(jsonDecode(response.body));
        final idx = localList.indexWhere((k) => k.id == toSave.id);
        if (idx != -1) {
          localList[idx] = serverKitab;
          await saveLocalKitabs(userId, localList);
        }
        return serverKitab;
      }
    } catch (_) {
      // Offline: will sync next time online!
    }

    return toSave;
  }

  static Future<Kitab?> updateKitab({
    required Kitab kitab,
    required String userId,
  }) async {
    // 1. Save locally immediately
    final localList = await getLocalKitabs(userId);
    final idx = localList.indexWhere((k) => k.id == kitab.id);
    if (idx != -1) {
      localList[idx] = kitab;
    } else {
      localList.add(kitab);
    }
    await saveLocalKitabs(userId, localList);

    // 2. Mark as pending sync
    await _addPendingSyncId(userId, kitab.id);

    // 3. Try syncing to MongoDB
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/kitabs/${kitab.id}'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
        body: jsonEncode(kitab.toJson()),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        await _removePendingSyncId(userId, kitab.id);
        return Kitab.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Offline: marked for sync next time online!
    }

    return kitab;
  }

  static Future<bool> deleteKitab({
    required String kitabId,
    required String userId,
  }) async {
    // 1. Delete from local storage immediately
    final localList = await getLocalKitabs(userId);
    localList.removeWhere((k) => k.id == kitabId);
    await saveLocalKitabs(userId, localList);

    // 2. Remove from pending sync, add to pending delete
    await _removePendingSyncId(userId, kitabId);
    await _addPendingDeleteId(userId, kitabId);

    // 3. Try deleting from MongoDB
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/kitabs/$kitabId'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        await _removePendingDeleteId(userId, kitabId);
      }
    } catch (_) {
      // Offline: marked for delete next time online!
    }

    return true;
  }
}
