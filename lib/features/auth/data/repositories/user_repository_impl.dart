import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_dao.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _dao = UserDao();

  @override
  Future<int> insertUser(UserEntity user) async {
    final model = UserModel(
        id: user.id,
        name: user.name,
        role: user.role,
        managerId: user.managerId,
        email: user.email,
        phone: user.phone);
    return await _dao.insertUser(model);
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final users = await _dao.getAllUsers();
    return users;
  }

  @override
  Future<UserEntity?> getUserById(int id) async {
    return await _dao.getUserById(id);
  }

  @override
  Future<UserEntity?> getUserByUsername(String username) {
    // Not implemented for Day 2 hardcoded/DB seed approach
    throw UnimplementedError();
  }
}
