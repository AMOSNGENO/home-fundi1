import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _tokenKey = 'home_fundi_api_token';
  static String get baseUrl => ApiConfig.baseUrl;

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) {
    return _request(
      path,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) {
    return _request(
      path,
      method: 'POST',
      payload: data,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? payload,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    final normalized = path.trim().replaceAll(RegExp(r'^/+'), '');
    final uri = Uri.parse('$baseUrl/$normalized').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, '$value'),
      ),
    );
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (authenticated) {
      final token = (await SharedPreferences.getInstance()).getString(_tokenKey);
      if (token == null || token.isEmpty) {
        throw const ApiException('Please log in first.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    late http.Response response;
    try {
      response = method == 'POST'
          ? await _client.post(
              uri,
              headers: headers,
              body: jsonEncode(payload ?? const {}),
            )
          : await _client.get(uri, headers: headers);
    } catch (error) {
      throw ApiException('Could not reach the API at $baseUrl. $error');
    }

    final decoded = _decode(response.body);
    final ok =
        response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded['status'] != 'error' &&
        decoded['success'] != false;
    if (!ok) {
      throw ApiException('${decoded['message'] ?? 'API request failed.'}');
    }
    return decoded;
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }
    throw const ApiException('API returned an invalid response.');
  }
}
