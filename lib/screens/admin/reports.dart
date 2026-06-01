import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic> _report = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.get('admin/reports.php');
    setState(() => _report = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('${_report['completed_jobs'] ?? 0}'),
              subtitle: const Text('Completed jobs'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(money(_report['revenue'] ?? 0)),
              subtitle: const Text('Revenue'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('${_report['average_rating'] ?? 0}'),
              subtitle: const Text('Average technician rating'),
            ),
          ),
          FilledButton.icon(
            onPressed: () => showToast(
              context,
              'Export endpoint is ready for server-side PDF/Excel generation.',
            ),
            icon: const Icon(Icons.download),
            label: const Text('Export report'),
          ),
        ],
      ),
    );
  }
}
