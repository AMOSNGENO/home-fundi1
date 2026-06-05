import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/repair_request.dart';
import '../../providers/auth_provider.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import 'technician_job_detail.dart';

class AvailableJobsScreen extends StatefulWidget {
  const AvailableJobsScreen({super.key});

  @override
  State<AvailableJobsScreen> createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends State<AvailableJobsScreen> {
  final _service = PhpApiService();
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
      _jobs = await _service.availableJobs();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
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
                      leading: job.requestImageUrl == null ||
                              job.requestImageUrl!.isEmpty
                          ? null
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                PhpApiService.mediaUrl(job.requestImageUrl),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                      title: Text(job.applianceName),
                      subtitle: Text(
                        '${job.address}'
                        '${job.estimatedCost == null || job.estimatedCost!.isEmpty ? '' : '\nQuote: ${money(job.estimatedCost)}'}'
                        '\n${job.description}',
                        maxLines: 3,
                      ),
                      isThreeLine: true,
                      trailing: FilledButton(
                        onPressed: () => _accept(job.id),
                        child: const Text('Accept'),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TechnicianJobDetailScreen(
                            job: job,
                            onChanged: _load,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _accept(String requestId) async {
    try {
      final technician = context.read<AuthProvider>().user!;
      await _service.acceptJob(requestId, technician);
      await _load();
      if (mounted) showToast(context, 'Job accepted.');
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
