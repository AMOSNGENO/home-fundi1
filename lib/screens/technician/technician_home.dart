import 'package:flutter/material.dart';

import '../../widgets/role_guard.dart';
import '../profile_screen.dart';
import 'available_jobs.dart';
import 'my_jobs.dart';
import 'technician_chats.dart';
import 'technician_dashboard.dart';

class TechnicianHome extends StatefulWidget {
  const TechnicianHome({super.key});

  @override
  State<TechnicianHome> createState() => _TechnicianHomeState();
}

class _TechnicianHomeState extends State<TechnicianHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      TechnicianDashboardScreen(),
      AvailableJobsScreen(),
      MyJobsScreen(),
      TechnicianChatsScreen(),
      ProfileScreen(),
    ];
    return RoleGuard(
      allowedRoles: const ['technician'],
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
              icon: Icon(Icons.assignment_outlined),
              label: 'Find Jobs',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              label: 'My Jobs',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chats',
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
