import 'package:flutter/material.dart';
import 'package:product_mgmt_app/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<bool> login(String mobile, String password) async {
    isLoading = true;
    notifyListeners();

    var result = await _authService.login(mobile, password);

    isLoading = false;
    notifyListeners();

    return result != null;
  }
}
