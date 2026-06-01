import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/request_provider.dart';
import 'providers/user_provider.dart';
import 'screens/admin/admin_home.dart';
import 'screens/customer/customer_home.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/technician/technician_home.dart';
import 'screens/vendor/vendor_home.dart';

void main() {
  runApp(const HomeFundiApp());
}

class HomeFundiApp extends StatelessWidget {
  const HomeFundiApp({super.key});

  static const _brandBlue = Color(0xFF0059A8);
  static const _brandRed = Color(0xFFD71920);
  static const _brandInk = Color(0xFF172033);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Home Fundi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _brandBlue,
            brightness: Brightness.light,
          ).copyWith(
            primary: _brandBlue,
            secondary: _brandRed,
            tertiary: _brandInk,
            surface: Colors.white,
            error: _brandRed,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: _brandInk,
            centerTitle: false,
            elevation: 0,
            surfaceTintColor: Colors.white,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: _brandBlue.withValues(alpha: .12),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? _brandBlue
                    : Colors.black54,
              ),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                color: states.contains(WidgetState.selected)
                    ? _brandBlue
                    : Colors.black54,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: _brandBlue,
              side: const BorderSide(color: _brandBlue),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: _brandRed,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _brandBlue, width: 1.6),
            ),
          ),
        ),
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
        if (auth.isLoading) return const SplashScreen();
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
