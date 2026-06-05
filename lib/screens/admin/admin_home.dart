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
              icon: Icon(Icons.home_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              label: 'Fundis',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              label: 'Jobs',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Finance',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
