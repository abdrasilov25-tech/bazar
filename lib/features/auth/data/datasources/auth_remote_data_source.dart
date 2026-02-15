import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  Future<UserEntity> login(String email, String password) async {
    // Имитируем задержку, как будто сеть
    await Future.delayed(const Duration(seconds: 1));
    return UserEntity(id: '123', email: email);
  }
}