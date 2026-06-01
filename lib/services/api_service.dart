import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class ApiService {
  static String baseUrl = AppConstants.baseUrl;
  static String? authToken;

  static Uri _uri(String path, [Map<String, String>? query]) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$root/$path').replace(queryParameters: query);
  }

  static Map<String, String> _headers() => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  static Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final response = await http.get(_uri(path, query), headers: _headers());
    return _decode(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  static Future<dynamic> delete(String path, Map<String, dynamic> body) async {
    final request = http.Request('DELETE', _uri(path))
      ..headers.addAll(_headers())
      ..body = jsonEncode(body);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  static dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (decoded is Map<String, dynamic> && decoded.containsKey('success')) {
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        throw ApiException(
          decoded['message']?.toString() ?? 'Request failed',
          response.statusCode,
        );
      }
      return decoded;
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['status'] == 'error') {
      throw ApiException(
        decoded['message']?.toString() ?? 'Request failed',
        response.statusCode,
      );
    }
    return decoded['data'];
  }
}
