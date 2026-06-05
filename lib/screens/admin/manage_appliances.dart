import 'package:flutter/material.dart';

import '../../models/appliance.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class ManageAppliancesScreen extends StatefulWidget {
  const ManageAppliancesScreen({super.key});

  @override
  State<ManageAppliancesScreen> createState() => _ManageAppliancesScreenState();
}

class _ManageAppliancesScreenState extends State<ManageAppliancesScreen> {
  final _service = PhpApiService();
  List<Appliance> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _service.appliances();
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Appliances'),
        actions: [
          const NotificationBellButton(color: Colors.white),
          IconButton(
            tooltip: 'Add',
            icon: const Icon(Icons.add),
            onPressed: () => _edit(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(item.category ?? ''),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(item),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(item.id),
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

  Future<void> _edit([Appliance? item]) async {
    final name = TextEditingController(text: item?.name);
    final category = TextEditingController(text: item?.category);
    final description = TextEditingController(text: item?.description);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add appliance' : 'Edit appliance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    try {
      final payload = {
        'name': name.text,
        'category': category.text,
        'description': description.text,
      };
      await _service.saveAppliance(item, payload);
      await _load();
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _service.deleteAppliance(id);
      await _load();
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
