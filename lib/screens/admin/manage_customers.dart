import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class ManageCustomersScreen extends StatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  State<ManageCustomersScreen> createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> {
  List<AppUser> _customers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.get(
      'admin/users.php',
      query: {'role': 'customer'},
    );
    setState(
      () => _customers = (data['users'] as List)
          .map((item) => AppUser.fromJson(item))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Customers')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _customers.length,
          itemBuilder: (context, index) {
            final user = _customers[index];
            return Card(
              child: ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(user.id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _delete(int id) async {
    try {
      await ApiService.delete('admin/delete_user.php', {'user_id': id});
      await _load();
    } on ApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
