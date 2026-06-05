import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class ManageTechniciansScreen extends StatefulWidget {
  const ManageTechniciansScreen({super.key});

  @override
  State<ManageTechniciansScreen> createState() =>
      _ManageTechniciansScreenState();
}

class _ManageTechniciansScreenState extends State<ManageTechniciansScreen> {
  final _service = PhpApiService();
  List<AppUser> _techs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final techs = await _service.users(role: 'technician');
    setState(() => _techs = techs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Technicians'),
        actions: [
          const NotificationBellButton(color: Colors.white),
          IconButton(
            tooltip: 'Add technician',
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _addTechnician,
          ),
        ],
      ),
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

  Future<void> _addTechnician() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    final skills = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add technician'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: skills,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Skills, for example fridge, cooker, washer',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Create'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    if (name.text.trim().isEmpty ||
        !email.text.contains('@') ||
        password.text.length < 6 ||
        phone.text.trim().isEmpty ||
        skills.text.trim().isEmpty) {
      if (mounted) {
        showToast(
          context,
          'Enter name, valid email, 6+ character password, phone and skills.',
          error: true,
        );
      }
      return;
    }

    try {
      await _service.createTechnicianAccount(
        name: name.text,
        email: email.text,
        password: password.text,
        phone: phone.text,
        address: address.text,
        skills: skills.text,
      );
      await _load();
      if (mounted) showToast(context, 'Technician account created.');
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }

  Future<void> _approve(String id, bool approved) async {
    try {
      await _service.approveTechnician(id, approved);
      await _load();
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
