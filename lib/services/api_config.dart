import 'config_service.dart';

class ApiConfig {
  const ApiConfig._();

  static String get baseUrl => _trimTrailingSlash(ConfigService.apiUrl);

  static String _trimTrailingSlash(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
