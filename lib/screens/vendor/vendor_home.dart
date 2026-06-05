import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';
import '../../widgets/role_guard.dart';
import '../profile_screen.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      VendorDashboardScreen(),
      VendorOrdersScreen(),
      ProfileScreen(),
    ];

    return RoleGuard(
      allowedRoles: const ['vendor'],
      child: Scaffold(
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              label: 'Vendor',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Orders',
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

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.storefront_outlined),
            title: Text('Parts and appliance supplies'),
            subtitle: Text('Manage service parts, stock, and vendor requests.'),
          ),
          ListTile(
            leading: Icon(Icons.pending_actions_outlined),
            title: Text('Pending requests'),
            subtitle: Text(
              'Review parts requests from technicians and admins.',
            ),
          ),
        ],
      ),
    );
  }
}

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Orders'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
      body: const Center(child: Text('Vendor orders will appear here.')),
    );
  }
}
