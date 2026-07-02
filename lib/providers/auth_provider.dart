import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> restoreSession() async {
    _user = await AuthService.getStoredUser();
    notifyListeners();
  }

  Future<bool> login(
      {required String username, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result =
          await AuthService.login(username: username, password: password);
      _user = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on Exception {
      _error = 'Không thể đăng nhập. Vui lòng thử lại.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
