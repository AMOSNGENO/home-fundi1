import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';
import '../models/appliance.dart';
import '../models/chat_message.dart';
import '../models/rating.dart';
import '../models/repair_request.dart';
import '../models/user.dart';
import 'api_config.dart';

class PhpApiException implements Exception {
  final String message;

  const PhpApiException(this.message);

  @override
  String toString() => message;
}

class PhpApiService {
  PhpApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _tokenKey = 'home_fundi_api_token';
  static const _userKey = 'home_fundi_user';
  static String get baseUrl => ApiConfig.baseUrl;
  static String mediaUrl(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    final root = Uri.parse('$baseUrl/');
    return root.resolve(value.startsWith('/') ? value.substring(1) : value).toString();
  }

  final http.Client _client;

  Future<AppUser?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;

    try {
      final body = await _request('auth/me.php');
      final user = AppUser.fromJson(_data(body, 'user'));
      await _saveSession(token, user);
      return user;
    } on PhpApiException {
      await _clearSession();
      return null;
    }
  }

  Future<AppUser> login(String identifier, String password) async {
    final login = identifier.trim();
    final body = await _request(
      'login.php',
      method: 'POST',
      payload: {
        'login': login,
        'email': login,
        'phone': login,
        'password': password,
      },
      authenticated: false,
    );
    final data = _map(body['data']);
    final token = '${body['token'] ?? data['token'] ?? ''}';
    if (token.isEmpty) {
      throw const PhpApiException('Login response did not include a token.');
    }
    final user = AppUser.fromJson(_map(body['user'] ?? data['user']));
    await _saveSession(token, user);
    return user;
  }

  Future<AppUser> register(Map<String, dynamic> payload) async {
    final body = await _request(
      'register.php',
      method: 'POST',
      payload: {...payload, 'role': payload['role'] ?? 'customer'},
      authenticated: false,
    );
    final userData = _data(body, 'user');
    final token = '${userData['token'] ?? body['token'] ?? ''}';
    if (token.isEmpty) {
      throw const PhpApiException(
        'Registration response did not include a token.',
      );
    }
    final user = AppUser.fromJson(userData);
    await _saveSession(token, user);
    return user;
  }

  Future<void> logout() async {
    try {
      await _request('logout.php', method: 'POST');
    } on PhpApiException {
      // Local logout should still succeed if the server token is already gone.
    }
    await _clearSession();
  }

  Future<String> sendPasswordReset(String email) async {
    final body = await _request(
      'request_password_reset.php',
      method: 'POST',
      payload: {'email': email.trim()},
      authenticated: false,
    );
    final data = _map(body['data']);
    final token = '${data['reset_token'] ?? ''}';
    final message =
        '${body['message'] ?? 'Password reset instructions prepared.'}';
    if (token.isEmpty) return message;
    return '$message Token: $token';
  }

  Future<List<AppUser>> users({String? role}) async {
    final current = await _cachedUser();
    if (current?.role == 'admin') {
      final body = await _request(
        'admin/users.php',
        queryParameters: {if (role != null) 'role': role},
      );
      return _list(body, 'users').map(AppUser.fromJson).toList();
    }
    if (role == 'technician') {
      final body = await _request('technicians.php');
      return _list(body, 'technicians').map(AppUser.fromJson).toList();
    }
    throw const PhpApiException('You cannot view these users.');
  }

  Future<void> deleteUser(String id) async {
    await _request(
      'admin/delete_user.php',
      method: 'POST',
      payload: {'user_id': id},
    );
  }

  Future<void> approveTechnician(String id, bool approved) async {
    await _request(
      'admin/approve_technician.php',
      method: 'POST',
      payload: {'user_id': id, 'approved': approved},
    );
  }

  Future<void> updateAvailability(String userId, bool available) async {
    await _request(
      'technician_profile.php',
      method: 'POST',
      payload: {'is_available': available ? 1 : 0},
    );
    final current = await _cachedUser();
    if (current != null && current.id == userId) {
      await _saveSession(
        (await SharedPreferences.getInstance()).getString(_tokenKey) ?? '',
        AppUser(
          id: current.id,
          name: current.name,
          email: current.email,
          phone: current.phone,
          address: current.address,
          role: current.role,
          accountStatus: current.accountStatus,
          isApproved: current.isApproved,
          profileImage: current.profileImage,
          skills: current.skills,
          isAvailable: available,
        ),
      );
    }
  }

  Future<AppUser> updateTechnicianProfile({
    required String email,
    required String phone,
    String? address,
    String? skills,
    String? profileImageData,
    String? profileImageName,
  }) async {
    final body = await _request(
      'technician_profile.php',
      method: 'POST',
      payload: {
        'email': email.trim(),
        'phone': phone.trim(),
        'address': address?.trim(),
        'skills': skills?.trim(),
        'profile_image_data': profileImageData,
        'profile_image_name': profileImageName,
      },
    );
    final user = AppUser.fromJson(_data(body, 'user'));
    await _saveSession(
      (await SharedPreferences.getInstance()).getString(_tokenKey) ?? '',
      user,
    );
    return user;
  }

  Future<AppUser> createTechnicianAccount({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String skills,
  }) async {
    final body = await _request(
      'register.php',
      method: 'POST',
      authenticated: false,
      payload: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone.trim(),
        'address': address.trim(),
        'role': 'technician',
        'skills': skills.trim(),
      },
    );
    final user = AppUser.fromJson(_data(body, 'user'));
    await approveTechnician(user.id, true);
    return AppUser(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      address: user.address,
      role: user.role,
      accountStatus: user.accountStatus,
      isApproved: true,
      profileImage: user.profileImage,
      skills: user.skills,
      isAvailable: user.isAvailable,
    );
  }

  Future<List<Appliance>> appliances() async {
    final body = await _request('appliances.php');
    return _list(body, 'appliances').map(Appliance.fromJson).toList();
  }

  Future<void> saveAppliance(
    Appliance? existing,
    Map<String, dynamic> data,
  ) async {
    await _request(
      existing == null
          ? 'admin/add_appliance.php'
          : 'admin/update_appliance.php',
      method: 'POST',
      payload: {
        if (existing != null) 'id': existing.id,
        'name': '${data['name'] ?? ''}'.trim(),
        'category': data['category'],
        'description': data['description'],
        'image_url': data['image_url'],
      },
    );
  }

  Future<void> deleteAppliance(String id) async {
    await _request(
      'admin/delete_appliance.php',
      method: 'POST',
      payload: {'id': id},
    );
  }

  Future<Map<String, dynamic>> createRepairRequest({
    required AppUser customer,
    required Appliance appliance,
    required String description,
    required String address,
    String? preferredDate,
    String? preferredTime,
    double? latitude,
    double? longitude,
    String? estimatedCost,
    String? requestImageData,
    String? requestImageName,
  }) async {
    final body = await _request(
      'repair_request.php',
      method: 'POST',
      payload: {
        'customer_id': customer.id,
        'appliance_id': appliance.id,
        'description': description,
        'preferred_date': preferredDate,
        'preferred_time': preferredTime,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'estimated_cost': estimatedCost == null || estimatedCost.trim().isEmpty
            ? null
            : estimatedCost.trim(),
        'request_image_data': requestImageData,
        'request_image_name': requestImageName,
      },
    );
    return _map(body['data']);
  }

  Future<List<RepairRequest>> customerRequests(String customerId) async {
    final body = await _request(
      'my_requests.php',
      queryParameters: {'customer_id': customerId},
    );
    return _list(body, 'requests').map(RepairRequest.fromJson).toList();
  }

  Future<List<RepairRequest>> technicianJobs(String technicianId) async {
    final body = await _request(
      'my_jobs.php',
      queryParameters: {'technician_id': technicianId},
    );
    return _list(body, 'jobs').map(RepairRequest.fromJson).toList();
  }

  Future<List<RepairRequest>> availableJobs() async {
    final body = await _request('available_jobs.php');
    return _list(body, 'jobs').map(RepairRequest.fromJson).toList();
  }

  Future<List<RepairRequest>> allRequests({String? status}) async {
    final body = await _request(
      'admin/repair_requests.php',
      queryParameters: {if (status != null) 'status': status},
    );
    return _list(body, 'requests').map(RepairRequest.fromJson).toList();
  }

  Future<void> cancelRequest(String requestId) async {
    await _request(
      'cancel_request.php',
      method: 'POST',
      payload: {'request_id': requestId},
    );
  }

  Future<void> acceptJob(String requestId, AppUser technician) async {
    await _request(
      'accept_job.php',
      method: 'POST',
      payload: {'request_id': requestId},
    );
  }

  Future<void> updateJobStatus(String requestId, String status) async {
    await _request(
      'update_job_status.php',
      method: 'POST',
      payload: {'request_id': requestId, 'status': status},
    );
  }

  Future<void> addRating({
    required RepairRequest request,
    required AppUser customer,
    required int rating,
    required String review,
  }) async {
    if (request.technicianId == null || request.technicianId!.isEmpty) {
      throw const PhpApiException('This request has no technician.');
    }
    await _request(
      'add_rating.php',
      method: 'POST',
      payload: {
        'repair_request_id': request.id,
        'technician_id': request.technicianId,
        'rating': rating,
        'review': review,
      },
    );
  }

  Future<List<RatingReview>> technicianRatings(String technicianId) async {
    final body = await _request('my_ratings.php');
    return _list(body, 'ratings').map(RatingReview.fromJson).toList();
  }

  Future<Map<String, dynamic>> dashboardStats() async {
    final body = await _request('admin/dashboard_stats.php');
    return _map(body['data']);
  }

  Future<Map<String, dynamic>> reports() async {
    final body = await _request('admin/reports.php');
    return _map(body['data']);
  }

  Future<List<AppNotification>> notifications() async {
    final body = await _request('notifications.php');
    return _list(body, 'notifications').map(AppNotification.fromJson).toList();
  }

  Future<void> markNotificationsRead() async {
    await _request(
      'notifications.php',
      method: 'POST',
      payload: {'mark_read': true},
    );
  }

  Future<List<ChatThread>> chatThreads() async {
    final body = await _request('chat_threads.php');
    return _list(body, 'threads').map(ChatThread.fromJson).toList();
  }

  Future<List<ChatMessage>> chatMessages({
    String? requestId,
    required String recipientId,
  }) async {
    final body = await _request(
      'chat_messages.php',
      queryParameters: {
        if (requestId != null) 'request_id': requestId,
        'recipient_id': recipientId,
      },
    );
    return _list(body, 'messages').map(ChatMessage.fromJson).toList();
  }

  Future<ChatMessage> sendChatMessage({
    String? requestId,
    required String recipientId,
    required String message,
  }) async {
    final body = await _request(
      'chat_messages.php',
      method: 'POST',
      payload: {
        if (requestId != null) 'request_id': requestId,
        'recipient_id': recipientId,
        'message': message.trim(),
      },
    );
    return ChatMessage.fromJson(_data(body, 'message'));
  }

  Future<void> seedDemoAccounts() async {
    throw const PhpApiException(
      'Demo accounts are seeded from database/home_fundi.sql.',
    );
  }

  Future<Map<String, dynamic>> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? payload,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$baseUrl/$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, '$value'),
      ),
    );
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authenticated) {
      final token = (await SharedPreferences.getInstance()).getString(_tokenKey);
      if (token == null || token.isEmpty) {
        throw const PhpApiException('Please log in first.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    late http.Response response;
    try {
      response = method == 'POST'
          ? await _client.post(
              uri,
              headers: headers,
              body: jsonEncode(payload ?? {}),
            )
          : await _client.get(uri, headers: headers);
    } catch (error) {
      throw PhpApiException(
        'Could not reach the API at $baseUrl. $error',
      );
    }

    late final Object? decoded;
    try {
      decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      throw PhpApiException(
        'API returned an invalid response from $uri.',
      );
    }
    final body = _map(decoded);
    final ok =
        response.statusCode >= 200 &&
        response.statusCode < 300 &&
        (body['status'] != 'error') &&
        (body['success'] != false);
    if (!ok) {
      throw PhpApiException(
        '${body['message'] ?? 'API request failed.'}',
      );
    }
    return body;
  }

  Future<AppUser?> _cachedUser() async {
    final raw = (await SharedPreferences.getInstance()).getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    return AppUser.fromJson(_map(jsonDecode(raw)));
  }

  Future<void> _saveSession(String token, AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    if (token.isNotEmpty) await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Map<String, dynamic> _data(Map<String, dynamic> body, String key) {
    final data = _map(body['data']);
    if (data.containsKey(key)) return _map(data[key]);
    return _map(body[key]);
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> body, String key) {
    final data = _map(body['data']);
    final value = data[key] ?? body[key] ?? const [];
    if (value is List) return value.map(_map).toList();
    return const [];
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry('$key', item));
    }
    return <String, dynamic>{};
  }
}
