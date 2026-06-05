import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class ManageCustomersScreen extends StatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  State<ManageCustomersScreen> createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> {
  final _service = PhpApiService();
  List<AppUser> _customers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customers = await _service.users(role: 'customer');
    setState(() => _customers = customers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Customers'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
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

  Future<void> _delete(String id) async {
    try {
      await _service.deleteUser(id);
      await _load();
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
