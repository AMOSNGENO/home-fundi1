import '../models/user.dart';
import 'php_api_service.dart';

class AuthService {
  final PhpApiService _api = PhpApiService();

  Future<AppUser?> loadUser() => _api.loadCurrentUser();

  Future<AppUser> login(String email, String password) {
    return _api.login(email, password);
  }

  Future<AppUser> register(Map<String, dynamic> payload) {
    return _api.register(payload);
  }

  Future<void> logout() => _api.logout();

  Future<String> sendPasswordReset(String email) {
    return _api.sendPasswordReset(email);
  }

  Future<AppUser> updateTechnicianProfile({
    required String email,
    required String phone,
    String? address,
    String? skills,
    String? profileImageData,
    String? profileImageName,
  }) {
    return _api.updateTechnicianProfile(
      email: email,
      phone: phone,
      address: address,
      skills: skills,
      profileImageData: profileImageData,
      profileImageName: profileImageName,
    );
  }
}
