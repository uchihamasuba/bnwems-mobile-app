import 'dart:convert';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../utils/storage_helper.dart';

class AuthService {
  /// POST /api/v1/auth/login
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'username': username,
      'password': password,
    });

    final token = response['data']['token'] as String;
    final user = UserModel.fromJson(response['data']['user'] as Map<String, dynamic>);

    await StorageHelper.saveToken(token);
    await StorageHelper.saveUser(jsonEncode(user.toJson()));

    return {'token': token, 'user': user};
  }

  /// PUT /api/v1/auth/change-password
  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ApiService.put('/auth/change-password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  /// Logout — clear all local storage.
  static Future<void> logout() async {
    await StorageHelper.clearAll();
  }
}
