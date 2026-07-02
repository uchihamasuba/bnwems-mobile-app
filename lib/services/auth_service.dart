import 'dart:convert';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/storage_helper.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'username': username,
      'password': password,
    });

    final token = response['data']['token'] as String;
    final user =
        UserModel.fromJson(response['data']['user'] as Map<String, dynamic>);

    _ensureMobileAccess(user);

    await StorageHelper.saveToken(token);
    await StorageHelper.saveUser(jsonEncode(user.toJson()));

    return {
      'token': token,
      'user': user,
    };
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ApiService.put('/auth/change-password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmNewPassword': newPassword,
    });
  }

  static Future<UserModel?> getStoredUser() async {
    final userJson = await StorageHelper.getUser();
    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(decoded);
      if (!user.canUseMobileApp) {
        await StorageHelper.clearAll();
        return null;
      }

      return user;
    } catch (_) {
      await StorageHelper.clearAll();
      return null;
    }
  }

  static Future<void> logout() async {
    await StorageHelper.clearAll();
  }

  static void _ensureMobileAccess(UserModel user) {
    if (!user.canUseMobileApp) {
      throw const ApiException(
        statusCode: 403,
        message: 'Tài khoản admin không được phép sử dụng ứng dụng mobile.',
      );
    }
  }
}
