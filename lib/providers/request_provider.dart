import 'package:flutter/foundation.dart';

import '../models/appliance.dart';
import '../models/repair_request.dart';
import '../services/api_service.dart';

class RequestProvider extends ChangeNotifier {
  bool loading = false;
  List<Appliance> appliances = [];
  List<RepairRequest> requests = [];

  Future<void> loadAppliances() async {
    final data = await ApiService.get('appliances.php');
    appliances = (data['appliances'] as List)
        .map((item) => Appliance.fromJson(item))
        .toList();
    notifyListeners();
  }

  Future<void> loadCustomerRequests(int customerId) async {
    loading = true;
    notifyListeners();
    final data = await ApiService.get(
      'my_requests.php',
      query: {'customer_id': '$customerId'},
    );
    requests = (data['requests'] as List)
        .map((item) => RepairRequest.fromJson(item))
        .toList();
    loading = false;
    notifyListeners();
  }

  Future<void> loadTechnicianJobs(int technicianId) async {
    loading = true;
    notifyListeners();
    final data = await ApiService.get(
      'my_jobs.php',
      query: {'technician_id': '$technicianId'},
    );
    requests = (data['jobs'] as List)
        .map((item) => RepairRequest.fromJson(item))
        .toList();
    loading = false;
    notifyListeners();
  }
}
