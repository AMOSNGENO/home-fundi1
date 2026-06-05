import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/repair_request.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/php_api_service.dart';
import '../../widgets/app_widgets.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final service = PhpApiService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroPanel(name: user.name),
            const SizedBox(height: 16),
            FutureBuilder<List<RepairRequest>>(
              future: service.customerRequests(user.id),
              builder: (context, snapshot) {
                final requests = snapshot.data ?? [];
                final pending = requests
                    .where((request) => request.status == 'pending')
                    .length;
                final active = requests
                    .where(
                      (request) =>
                          request.status == 'accepted' ||
                          request.status == 'in_progress',
                    )
                    .length;
                final completed = requests
                    .where((request) => request.status == 'completed')
                    .length;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard('Total', requests.length, Icons.receipt_long),
                    _MetricCard('Pending', pending, Icons.pending_actions),
                    _MetricCard('Active', active, Icons.handyman),
                    _MetricCard('Completed', completed, Icons.verified),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Nearby verified technicians',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<AppUser>>(
              future: service.users(role: 'technician'),
              builder: (context, snapshot) {
                final technicians = (snapshot.data ?? [])
                    .where((tech) => tech.isApproved)
                    .take(5)
                    .toList();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (technicians.isEmpty) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(Icons.engineering_outlined),
                      title: Text('No verified technicians yet'),
                    ),
                  );
                }
                return Column(
                  children: technicians
                      .map(
                        (tech) => Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.verified),
                            ),
                            title: Text(tech.name),
                            subtitle: Text(tech.skills ?? ''),
                            trailing: Chip(
                              label: Text(
                                tech.isAvailable ? 'Available' : 'Busy',
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF116149), Color(0xFF1E8A68)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${name.isEmpty ? 'Homeowner' : name}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Request trusted appliance repairs and track every job in real time.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 700 ? 160 : 150,
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF116149)),
          title: Text('$value', style: Theme.of(context).textTheme.titleLarge),
          subtitle: Text(label),
        ),
      ),
    );
  }
}
