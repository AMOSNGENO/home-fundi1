import 'package:flutter/material.dart';

import '../../models/repair_request.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class AvailableJobsScreen extends StatefulWidget {
  const AvailableJobsScreen({super.key});

  @override
  State<AvailableJobsScreen> createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends State<AvailableJobsScreen> {
  List<RepairRequest> _jobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.get('available_jobs.php');
      _jobs = (data['jobs'] as List)
          .map((item) => RepairRequest.fromJson(item))
          .toList();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Jobs')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return Card(
                    child: ListTile(
                      title: Text(job.applianceName),
                      subtitle: Text(
                        '${job.address}\n${job.description}',
                        maxLines: 3,
                      ),
                      isThreeLine: true,
                      trailing: FilledButton(
                        onPressed: () => _accept(job.id),
                        child: const Text('Accept'),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _accept(int requestId) async {
    try {
      await ApiService.post('accept_job.php', {'request_id': requestId});
      await _load();
      if (mounted) showToast(context, 'Job accepted.');
    } on ApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
