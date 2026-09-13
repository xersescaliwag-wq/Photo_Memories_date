import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class AuthUser {
  final int userId;
  final String username;
  final String email;

  const AuthUser({
    required this.userId,
    required this.username,
    required this.email,
  });
}

class MemoryData {
  final String memoryDate;
  final String imageUrl;

  const MemoryData({
    required this.memoryDate,
    required this.imageUrl,
  });
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}/$path');

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body is Map<String, dynamic> ? body : {};
    } on FormatException {
      throw ApiException(
        'Invalid server response (HTTP ${response.statusCode})',
      );
    }
  }

  void _ensureSuccess(http.Response response, Map<String, dynamic> data) {
    if (data['success'] != true) {
      throw ApiException(data['message']?.toString() ?? 'Request failed');
    }
  }

  Future<AuthUser> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await _client
        .post(
          _uri('register.php'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
          },
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = _decode(response);
    _ensureSuccess(response, data);
    final user = data['user'] as Map<String, dynamic>;
    return AuthUser(
      userId: user['user_id'] as int,
      username: user['username'] as String,
      email: user['email'] as String,
    );
  }

  Future<AuthUser> login(String identifier, String password) async {
    final response = await _client
        .post(
          _uri('login.php'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
          },
          body: jsonEncode({
            'identifier': identifier,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = _decode(response);
    _ensureSuccess(response, data);
    final user = data['user'] as Map<String, dynamic>;
    return AuthUser(
      userId: user['user_id'] as int,
      username: user['username'] as String,
      email: user['email'] as String,
    );
  }

  Future<List<MemoryData>> getMemories(int userId) async {
    final response = await _client
        .get(
          _uri('get_memories.php?user_id=$userId'),
          headers: {'ngrok-skip-browser-warning': '1'},
        )
        .timeout(const Duration(seconds: 15));

    final data = _decode(response);
    _ensureSuccess(response, data);
    final list = data['memories'] as List<dynamic>? ?? [];
    return list
        .map((e) => MemoryData(
              memoryDate: e['memory_date'] as String,
              imageUrl: e['image_url'] as String,
            ))
        .toList();
  }

  Future<bool> ping() async {
    try {
      final response = await _client
          .get(
            _uri('get_memories.php?user_id=0'),
            headers: {'ngrok-skip-browser-warning': '1'},
          )
          .timeout(const Duration(seconds: 6));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<MemoryData> uploadMemory(
    int userId,
    String dateKey,
    File image,
  ) async {
    final request = http.MultipartRequest('POST', _uri('upload.php'))
      ..headers['ngrok-skip-browser-warning'] = '1'
      ..fields['user_id'] = '$userId'
      ..fields['memory_date'] = dateKey
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamed =
        await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    final data = _decode(response);
    _ensureSuccess(response, data);
    if (response.statusCode != 201) {
      throw ApiException(data['message']?.toString() ?? 'Upload failed');
    }
    final memory = data['memory'] as Map<String, dynamic>;
    return MemoryData(
      memoryDate: memory['memory_date'] as String,
      imageUrl: memory['image_url'] as String,
    );
  }

  Future<void> deleteMemory(int userId, String dateKey) async {
    final response = await _client
        .post(
          _uri('delete_memory.php'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
          },
          body: jsonEncode({
            'user_id': userId,
            'memory_date': dateKey,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = _decode(response);
    _ensureSuccess(response, data);
  }

  Future<void> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    final response = await _client
        .post(
          _uri('change_password.php'),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1',
          },
          body: jsonEncode({
            'user_id': userId,
            'old_password': oldPassword,
            'new_password': newPassword,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = _decode(response);
    _ensureSuccess(response, data);
  }

  Future<void> deleteAccount(int userId) async {
    const int maxAttempts = 3;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _client
            .post(
              _uri('delete_account.php'),
              headers: {
                'Content-Type': 'application/json',
                'ngrok-skip-browser-warning': '1',
              },
              body: jsonEncode({
                'user_id': userId,
              }),
            )
            .timeout(const Duration(seconds: 15));

        final isTransient = response.statusCode == 502 ||
            response.statusCode == 503 ||
            response.statusCode == 504;
        if (isTransient && attempt < maxAttempts) {
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }

        final data = _decode(response);
        _ensureSuccess(response, data);
        return;
      } catch (_) {
        if (attempt < maxAttempts) {
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }
        rethrow;
      }
    }
  }
}
