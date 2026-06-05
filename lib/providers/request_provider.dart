import 'package:flutter/foundation.dart';

import '../models/appliance.dart';
import '../models/repair_request.dart';
import '../services/php_api_service.dart';

class RequestProvider extends ChangeNotifier {
  final _service = PhpApiService();

  bool loading = false;
  String? errorMessage;
  List<Appliance> appliances = [];
  List<RepairRequest> requests = [];

  Future<void> loadAppliances() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      appliances = await _service.appliances();
    } catch (error) {
      errorMessage = 'Could not load appliances.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> loadCustomerRequests(String customerId) async {
    loading = true;
    notifyListeners();
    try {
      requests = await _service.customerRequests(customerId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadTechnicianJobs(String technicianId) async {
    loading = true;
    notifyListeners();
    try {
      requests = await _service.technicianJobs(technicianId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
