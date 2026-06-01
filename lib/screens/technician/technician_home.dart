import 'package:flutter/material.dart';

import '../../widgets/role_guard.dart';
import '../profile_screen.dart';
import 'available_jobs.dart';
import 'my_jobs.dart';
import 'my_ratings.dart';
import 'update_status.dart';

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
      AvailableJobsScreen(),
      MyJobsScreen(),
      UpdateStatusScreen(),
      MyRatingsScreen(),
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
              icon: Icon(Icons.work_outline),
              label: 'Jobs',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              label: 'Mine',
            ),
            NavigationDestination(icon: Icon(Icons.update), label: 'Status'),
            NavigationDestination(
              icon: Icon(Icons.star_outline),
              label: 'Ratings',
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
