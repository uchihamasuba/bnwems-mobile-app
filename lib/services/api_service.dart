import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage_helper.dart';

/// Base URL — override via app config for different environments.
const String _baseUrl = 'http://10.0.2.2:3001/api/v1'; // 10.0.2.2 = Android emulator localhost

class ApiService {
  static final http.Client _client = http.Client();

  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path) async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl$path'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl$path'),
          headers: await _authHeaders(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await _client
        .put(
          Uri.parse('$_baseUrl$path'),
          headers: await _authHeaders(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final response = await _client
        .patch(
          Uri.parse('$_baseUrl$path'),
          headers: await _authHeaders(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else if (response.statusCode == 401) {
      throw const ApiException(statusCode: 401, message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: data['message'] as String? ?? 'Lỗi không xác định.',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
