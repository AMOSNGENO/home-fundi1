import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class DashboardStatsScreen extends StatefulWidget {
  const DashboardStatsScreen({super.key});

  @override
  State<DashboardStatsScreen> createState() => _DashboardStatsScreenState();
}

class _DashboardStatsScreenState extends State<DashboardStatsScreen> {
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.get('admin/dashboard_stats.php');
    setState(() => _stats = data);
  }

  @override
  Widget build(BuildContext context) {
    final cards = {
      'Users': _stats['total_users'] ?? 0,
      'Technicians': _stats['total_technicians'] ?? 0,
      'Requests': _stats['total_requests'] ?? 0,
      'Completed': _stats['completed_jobs'] ?? 0,
      'Revenue': money(_stats['revenue'] ?? 0),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
          childAspectRatio: 1.25,
          children: cards.entries
              .map(
                (entry) => Card(
                  child: Center(
                    child: ListTile(
                      title: Text(
                        '${entry.value}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      subtitle: Text(entry.key),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
