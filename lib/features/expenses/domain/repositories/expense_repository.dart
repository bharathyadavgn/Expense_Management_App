import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<int> insertExpense(ExpenseEntity expense);


  Future<List<ExpenseEntity>> getExpensesByReport(int reportId);

  Future<void> deleteExpense(int id);
}
