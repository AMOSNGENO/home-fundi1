import 'package:flutter/material.dart';

import '../../models/repair_request.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class AllRequestsScreen extends StatefulWidget {
  const AllRequestsScreen({super.key});

  @override
  State<AllRequestsScreen> createState() => _AllRequestsScreenState();
}

class _AllRequestsScreenState extends State<AllRequestsScreen> {
  final _service = PhpApiService();
  List<RepairRequest> _requests = [];
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final requests = await _service.allRequests(status: _status);
    setState(() => _requests = requests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Repair Requests'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String?>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Filter by status'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                DropdownMenuItem(
                  value: 'in_progress',
                  child: Text('In progress'),
                ),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                setState(() => _status = value);
                _load();
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final item = _requests[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${item.applianceName} - ${item.customerName}',
                      ),
                      subtitle: Text(
                        '${item.technicianName ?? 'Unassigned'}\n${readableStatus(item.status)}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
