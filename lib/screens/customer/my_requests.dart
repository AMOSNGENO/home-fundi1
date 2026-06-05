import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import 'rate_technician.dart';
import '../../widgets/app_widgets.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _service = PhpApiService();

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() => context.read<RequestProvider>().loadCustomerRequests(
    context.read<AuthProvider>().user!.id,
  );

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<RequestProvider>().requests;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final item = requests[index];
            return Card(
              child: ListTile(
                leading: item.requestImageUrl == null ||
                        item.requestImageUrl!.isEmpty
                    ? null
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          PhpApiService.mediaUrl(item.requestImageUrl),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                title: Text(item.applianceName),
                subtitle: Text(
                  '${readableStatus(item.status)}'
                  '${item.technicianName == null ? '' : ' - ${item.technicianName}'}'
                  '${item.estimatedCost == null || item.estimatedCost!.isEmpty ? '' : '\nQuote: ${money(item.estimatedCost)}'}'
                  '\n${item.description}',
                  maxLines: 3,
                ),
                isThreeLine: true,
                trailing: item.status == 'completed'
                    ? IconButton(
                        tooltip: 'Rate technician',
                        icon: const Icon(Icons.star_rate),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RateTechnicianScreen(request: item),
                          ),
                        ),
                      )
                    : item.status == 'pending'
                    ? IconButton(
                        tooltip: 'Cancel',
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () => _cancel(item.id),
                      )
                    : Chip(
                        label: Text(readableStatus(item.status)),
                        backgroundColor: statusColor(
                          item.status,
                        ).withValues(alpha: .15),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _cancel(String id) async {
    try {
      await _service.cancelRequest(id);
      await _load();
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
