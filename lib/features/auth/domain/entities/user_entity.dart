// lib/features/auth/domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;

  const UserEntity({
    required this.id,
    required this.email,
  });
}