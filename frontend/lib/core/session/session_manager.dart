import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager instance = SessionManager._internal();
  SessionManager._internal();

  static const String _prefTokenKey = 'landtrust_auth_token';
  static const String _prefUserKey = 'landtrust_current_user';

  String? token;
  Map<String, dynamic>? currentUser;

  bool get isAuthenticated => token != null && token!.isNotEmpty;
  bool get isLoggedIn => isAuthenticated;
  String get userRole => currentUser?['role']?.toString() ?? 'BUYER';
  bool get isAdmin => userRole == 'ADMIN';
  bool get isMarketingOfficer => userRole == 'MARKETING_OFFICER';

  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_prefTokenKey);
      final savedUserJson = prefs.getString(_prefUserKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        token = savedToken;
        if (savedUserJson != null && savedUserJson.isNotEmpty) {
          currentUser = jsonDecode(savedUserJson) as Map<String, dynamic>;
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadSession() => restoreSession();

  Future<void> saveSession(String newToken, Map<String, dynamic> user) async {
    token = newToken;
    currentUser = user;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefTokenKey, newToken);
      await prefs.setString(_prefUserKey, jsonEncode(user));
    } catch (_) {}
  }

  Future<void> updateCurrentUser(Map<String, dynamic> user) async {
    currentUser = user;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefUserKey, jsonEncode(user));
    } catch (_) {}
  }

  Future<void> clearSession() async {
    token = null;
    currentUser = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefTokenKey);
      await prefs.remove(_prefUserKey);
    } catch (_) {}
  }
}
