import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static const _userKey = 'home_fundi_user';

  Future<AppUser?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    final user = AppUser.fromJson(jsonDecode(raw));
    ApiService.authToken = user.token;
    try {
      final data = await ApiService.get('auth/me.php');
      final userJson = Map<String, dynamic>.from(data['user']);
      userJson['token'] ??= user.token;
      final freshUser = AppUser.fromJson(userJson);
      await _save(freshUser);
      return freshUser;
    } on ApiException {
      await logout();
      return null;
    }
  }

  Future<AppUser> login(String email, String password) async {
    final data = await ApiService.post('login.php', {
      'login': email,
      'email': email,
      'password': password,
    });
    final userJson = Map<String, dynamic>.from(data['user']);
    userJson['token'] ??= data['token'];
    final user = AppUser.fromJson(userJson);
    await _save(user);
    return user;
  }

  Future<AppUser> register(Map<String, dynamic> payload) async {
    final data = await ApiService.post('register.php', payload);
    final user = AppUser.fromJson(data['user']);
    await _save(user);
    return user;
  }

  Future<void> logout() async {
    try {
      if (ApiService.authToken != null) {
        await ApiService.post('logout.php', {});
      }
    } catch (_) {
      // Local logout should still complete if the token has already expired.
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      ApiService.authToken = null;
    }
  }

  Future<void> _save(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    ApiService.authToken = user.token;
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
