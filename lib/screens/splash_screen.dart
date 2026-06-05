import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.gradientSplash,
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage('assets/homefundi_logo.png'),
                width: 280,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 12),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.primaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}
