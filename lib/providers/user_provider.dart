import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/php_api_service.dart';

class UserProvider extends ChangeNotifier {
  final _service = PhpApiService();

  bool loading = false;
  List<AppUser> users = [];

  Future<void> loadUsers({String? role}) async {
    loading = true;
    notifyListeners();
    try {
      users = await _service.users(role: role);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
