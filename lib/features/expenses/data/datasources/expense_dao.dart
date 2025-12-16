import '../../../../core/database/db_helper.dart';
import '../models/expense_model.dart';

class ExpenseDao {
  final dbProvider = DBHelper.database;

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await dbProvider;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> getExpensesByReport(int reportId) async {
    final db = await dbProvider;
    final maps = await db.query(
      'expenses',
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
    return maps.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<List<ExpenseModel>> getExpensesByUser(int userId) async {
    final db = await dbProvider;
    final maps = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<void> deleteExpense(int id) async {
    final db = await dbProvider;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
