import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 42,
            child: Text(user.name.isEmpty ? 'U' : user.name[0].toUpperCase()),
          ),
          const SizedBox(height: 18),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text(user.name),
            subtitle: Text(user.role.toUpperCase()),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(user.phone),
          ),
          if (user.address != null)
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(user.address!),
            ),
          if (user.role == 'technician')
            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: Text(
                user.isApproved
                    ? 'Approved technician'
                    : 'Pending admin approval',
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
