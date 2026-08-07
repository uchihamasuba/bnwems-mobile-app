import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/storage_helper.dart';

const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

class ApiService {
  static final http.Client _client = http.Client();

  static List<String> get _baseUrls {
    if (_configuredBaseUrl.isNotEmpty) {
      return [_configuredBaseUrl];
    }

    if (kIsWeb) {
      return const [
        'http://localhost:3000/api/v1',
        'http://localhost:3001/api/v1',
      ];
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const [
          'http://10.0.2.2:3001/api/v1',
          'http://10.0.2.2:3000/api/v1',
        ];
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const [
          'http://localhost:3001/api/v1',
          'http://localhost:3000/api/v1',
        ];
    }
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path) async {
    final response = await _sendWithFallback(
      (baseUrl, headers) => _client
          .get(
            Uri.parse('$baseUrl$path'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15)),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _sendWithFallback(
      (baseUrl, headers) => _client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15)),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await _sendWithFallback(
      (baseUrl, headers) => _client
          .put(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15)),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final response = await _sendWithFallback(
      (baseUrl, headers) => _client
          .patch(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15)),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path) async {
    final response = await _sendWithFallback(
      (baseUrl, headers) => _client
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15)),
    );
    return _handleResponse(response);
  }

  static Future<http.Response> _sendWithFallback(
    Future<http.Response> Function(String baseUrl, Map<String, String> headers)
        send,
  ) async {
    final headers = await _authHeaders();

    for (final baseUrl in _baseUrls) {
      try {
        return await send(baseUrl, headers);
      } catch (error, stackTrace) {
        developer.log('Network request failed for $baseUrl', error: error, stackTrace: stackTrace);
        continue;
      }
    }

    throw ApiException(
      statusCode: 0,
      message:
          'Không kết nối được backend trên cổng 3000 hoặc 3001. Hãy kiểm tra server.',
    );
  }

  static dynamic _handleResponse(http.Response response) {
    final rawBody = response.body.trim();
    final data = rawBody.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(rawBody) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: data['message'] as String? ??
          (response.statusCode == 401
              ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
              : 'Lỗi không xác định.'),
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
