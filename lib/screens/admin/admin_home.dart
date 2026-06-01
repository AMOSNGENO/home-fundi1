import 'package:flutter/material.dart';

import '../../widgets/role_guard.dart';
import '../profile_screen.dart';
import 'all_requests.dart';
import 'dashboard_stats.dart';
import 'manage_appliances.dart';
import 'manage_customers.dart';
import 'manage_technicians.dart';
import 'reports.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DashboardStatsScreen(),
      ManageTechniciansScreen(),
      ManageCustomersScreen(),
      ManageAppliancesScreen(),
      AllRequestsScreen(),
      ReportsScreen(),
      ProfileScreen(),
    ];
    return RoleGuard(
      allowedRoles: const ['admin'],
      child: Scaffold(
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.engineering_outlined),
              label: 'Techs',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.kitchen_outlined),
              label: 'Items',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
