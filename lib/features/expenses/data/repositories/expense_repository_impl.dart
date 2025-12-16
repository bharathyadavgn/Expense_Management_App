import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_dao.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDao _dao = ExpenseDao();

  
  // INSERT
  
  @override
  Future<int> insertExpense(ExpenseEntity expense) async {
    final model = ExpenseModel(
      id: expense.id,
      reportId: expense.reportId,
      userId: expense.userId,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      merchant: expense.merchant,
      description: expense.description,
      receiptPath: expense.receiptPath,
    );
    return await _dao.insertExpense(model);
  }

  
  // DELETE
  
  @override
  Future<void> deleteExpense(int id) async {
    await _dao.deleteExpense(id);
  }

  
  // GET EXPENSES BY REPORT
  
  @override
  Future<List<ExpenseEntity>> getExpensesByReport(int reportId) async {
    final models = await _dao.getExpensesByReport(reportId);
    return models.map((m) => _toEntity(m)).toList();
  }


  @override
  Future<List<ExpenseEntity>> getExpensesByUser(int userId) async {
    final models = await _dao.getExpensesByUser(userId);
    return models.map((m) => _toEntity(m)).toList();
  }

  
  // MODEL → ENTITY MAPPER
  
  ExpenseEntity _toEntity(ExpenseModel m) {
    return ExpenseEntity(
      id: m.id,
      reportId: m.reportId,
      userId: m.userId,
      amount: m.amount,
      category: m.category,
      date: m.date,
      merchant: m.merchant,
      description: m.description,
      receiptPath: m.receiptPath,
    );
  }
}
