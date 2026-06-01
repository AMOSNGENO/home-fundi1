import 'package:flutter/foundation.dart';

class AppConstants {
  static const appName = 'Home Fundi';

  // Android emulator: http://10.0.2.2/home_fundi_api
  // Physical phone: use your PC LAN IP, for example http://192.168.1.10/home_fundi_api
  static const _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static final String baseUrl = _configuredBaseUrl.isNotEmpty
      ? _configuredBaseUrl
      : _defaultBaseUrl;

  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://localhost/home_fundi_api';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2/home_fundi_api',
      TargetPlatform.iOS ||
      TargetPlatform.windows ||
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => 'http://localhost/home_fundi_api',
    };
  }

  static const statuses = [
    'pending',
    'accepted',
    'in_progress',
    'completed',
    'cancelled',
  ];
}
