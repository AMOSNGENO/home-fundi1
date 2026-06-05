import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  static String apiUrl = '';
  
  static Future<void> loadConfig() async {
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      final configJson = json.decode(configString);
      apiUrl = configJson['apiUrl'];
      print('API URL loaded: $apiUrl');
    } catch (e) {
      print('Error loading config: $e');
      // Fallback URL
      apiUrl = 'http://127.0.0.1/Home-Fundi/api';
    }
  }
}
