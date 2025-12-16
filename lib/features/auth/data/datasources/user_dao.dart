import '../../../../core/database/db_helper.dart';
import '../models/user_model.dart';

class UserDao {
  final dbProvider = DBHelper.database;

  Future<int> insertUser(UserModel user) async {
    final db = await dbProvider;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await dbProvider;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await dbProvider;
    final maps = await db.query('users');
    return maps.map((m) => UserModel.fromMap(m)).toList();
  }
}
