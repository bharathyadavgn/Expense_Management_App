import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserById(int id);

  Future<UserEntity?> getUserByUsername(
      String username); // placeholder for future
  Future<List<UserEntity>> getAllUsers();

  Future<int> insertUser(UserEntity user);
}
