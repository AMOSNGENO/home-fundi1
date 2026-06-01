import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class ManageTechniciansScreen extends StatefulWidget {
  const ManageTechniciansScreen({super.key});

  @override
  State<ManageTechniciansScreen> createState() =>
      _ManageTechniciansScreenState();
}

class _ManageTechniciansScreenState extends State<ManageTechniciansScreen> {
  List<AppUser> _techs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.get(
      'admin/users.php',
      query: {'role': 'technician'},
    );
    setState(
      () => _techs = (data['users'] as List)
          .map((item) => AppUser.fromJson(item))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Technicians')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _techs.length,
          itemBuilder: (context, index) {
            final tech = _techs[index];
            return Card(
              child: ListTile(
                title: Text(tech.name),
                subtitle: Text('${tech.email}\n${tech.skills ?? ''}'),
                isThreeLine: true,
                trailing: tech.isApproved
                    ? const Chip(label: Text('Approved'))
                    : Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Approve',
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => _approve(tech.id, true),
                          ),
                          IconButton(
                            tooltip: 'Reject',
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _approve(tech.id, false),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _approve(int id, bool approved) async {
    try {
      await ApiService.post('admin/approve_technician.php', {
        'user_id': id,
        'approved': approved,
      });
      await _load();
    } on ApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
