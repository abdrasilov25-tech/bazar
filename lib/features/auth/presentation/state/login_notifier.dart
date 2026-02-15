import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginNotifier extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  bool isLoading = false;

  LoginNotifier(this.loginUseCase);

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    await loginUseCase(email, password);

    isLoading = false;
    notifyListeners();
  }
}