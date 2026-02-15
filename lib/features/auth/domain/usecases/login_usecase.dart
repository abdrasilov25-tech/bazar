import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future call(String email, String password) {
    return repository.login(email, password);
  }
}