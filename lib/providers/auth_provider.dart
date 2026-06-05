import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();
  AppUser? user;
  bool isLoading = true;
  bool hasLoadedSession = false;

  bool get isLoggedIn => user != null;

  Future<void> loadSession() async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _service.loadUser();
    } finally {
      hasLoadedSession = true;
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

  Future<String> sendPasswordReset(String email) {
    return _service.sendPasswordReset(email);
  }

  Future<void> updateTechnicianProfile({
    required String email,
    required String phone,
    String? address,
    String? skills,
    String? profileImageData,
    String? profileImageName,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _service.updateTechnicianProfile(
        email: email,
        phone: phone,
        address: address,
        skills: skills,
        profileImageData: profileImageData,
        profileImageName: profileImageName,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
