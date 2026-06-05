import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';

class UpdateStatusScreen extends StatefulWidget {
  const UpdateStatusScreen({super.key});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  final _service = PhpApiService();

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() => context.read<RequestProvider>().loadTechnicianJobs(
    context.read<AuthProvider>().user!.id,
  );

  @override
  Widget build(BuildContext context) {
    final active = context
        .watch<RequestProvider>()
        .requests
        .where((job) => job.status == 'accepted' || job.status == 'in_progress')
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Update Status')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: active.length,
          itemBuilder: (context, index) {
            final job = active[index];
            return Card(
              child: ListTile(
                title: Text(job.applianceName),
                subtitle: Text(readableStatus(job.status)),
                trailing: DropdownButton<String>(
                  value: job.status,
                  items: const [
                    DropdownMenuItem(
                      value: 'accepted',
                      child: Text('Accepted'),
                    ),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('In progress'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (value) =>
                      value == null ? null : _update(job.id, value),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _update(String id, String status) async {
    try {
      await _service.updateJobStatus(id, status);
      await _load();
      if (mounted) showToast(context, 'Status updated.');
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
