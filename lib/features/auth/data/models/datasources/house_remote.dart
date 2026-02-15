import '../user_model.dart';

class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password) async {
    // Фейковая задержка, без Firebase
    await Future.delayed(const Duration(seconds: 1));

    return UserModel(
      id: '123',
      email: email,
    );
  }
}