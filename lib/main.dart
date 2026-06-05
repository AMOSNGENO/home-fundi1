import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/request_provider.dart';
import 'providers/user_provider.dart';
import 'screens/admin/admin_home.dart';
import 'screens/customer/customer_home.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/technician/technician_home.dart';
import 'screens/vendor/vendor_home.dart';
import 'services/config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.loadConfig();
  // Local notifications are initialized in NotificationProvider.init().
  runApp(const HomeFundiApp());
}

class HomeFundiApp extends StatelessWidget {
  const HomeFundiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..init(),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppGate(),
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.hasLoadedSession) return const SplashScreen();
        if (!auth.isLoggedIn) return const LoginScreen();
        final user = auth.user!;
        if (user.role == 'admin') return const AdminHome();
        if (user.role == 'technician') return const TechnicianHome();
        if (user.role == 'vendor') return const VendorHome();
        return const CustomerHome();
      },
    );
  }
}
