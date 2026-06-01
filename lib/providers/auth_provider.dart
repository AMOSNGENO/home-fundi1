import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();
  AppUser? user;
  bool isLoading = true;

  bool get isLoggedIn => user != null;

  Future<void> loadSession() async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _service.loadUser();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _service.login(email, password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> payload) async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _service.register(payload);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    user = null;
    notifyListeners();
  }
}
