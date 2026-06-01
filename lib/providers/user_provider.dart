import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  bool loading = false;
  List<AppUser> users = [];

  Future<void> loadUsers({String? role}) async {
    loading = true;
    notifyListeners();
    final data = await ApiService.get(
      'admin/users.php',
      query: role == null ? null : {'role': role},
    );
    users = (data['users'] as List)
        .map((item) => AppUser.fromJson(item))
        .toList();
    loading = false;
    notifyListeners();
  }
}
