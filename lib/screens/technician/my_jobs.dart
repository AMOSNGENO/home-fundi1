import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../utils/helpers.dart';
import 'technician_job_detail.dart';
import '../../widgets/app_widgets.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
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
    final jobs = context.watch<RequestProvider>().requests;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Jobs'),
          actions: const [
            NotificationBellButton(color: Colors.white),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: TabBarView(
            children: [
              _list(
                jobs
                    .where(
                      (j) =>
                          j.status == 'accepted' || j.status == 'in_progress',
                    )
                    .toList(),
              ),
              _list(jobs.where((j) => j.status == 'completed').toList()),
              _list(jobs.where((j) => j.status == 'cancelled').toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(List jobs) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          child: ListTile(
            title: Text(job.applianceName),
            subtitle: Text(
              '${readableStatus(job.status)}\n${job.address}',
              maxLines: 3,
            ),
            isThreeLine: true,
            trailing: Text(money(job.actualCost ?? job.estimatedCost ?? 0)),
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
    );
  }
}
