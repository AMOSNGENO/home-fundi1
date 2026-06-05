import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import '../profile_screen.dart';
import 'customer_dashboard.dart';
import 'find_technicians.dart';
import 'my_requests.dart';
import 'track_request.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pages = [
      const CustomerDashboardScreen(),
      const FindTechniciansScreen(),
      const MyRequestsScreen(),
      const TrackRequestScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Get Fundi',
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Requests',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(
              auth.isLoggedIn ? Icons.person_outline : Icons.login_outlined,
            ),
            label: auth.isLoggedIn ? 'Profile' : 'Login',
          ),
        ],
      ),
    );
  }
}

Future<bool> requireCustomerLogin(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  if (auth.isLoggedIn) return true;

  final loggedIn = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const LoginScreen(popOnSuccess: true)),
  );

  if (!context.mounted) return false;
  final user = context.read<AuthProvider>().user;
  return loggedIn == true && user != null && user.role == 'customer';
}
