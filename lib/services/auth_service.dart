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
    final user = UserModel.fromJson(response['data']['user'] as Map<String, dynamic>);

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

    final decoded = jsonDecode(userJson) as Map<String, dynamic>;
    return UserModel.fromJson(decoded);
  }

  static Future<void> logout() async {
    await StorageHelper.clearAll();
  }
}
