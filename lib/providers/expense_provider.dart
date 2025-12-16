import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../features/expenses/domain/entities/expense_entity.dart';
import '../features/expenses/data/repositories/expense_repository_impl.dart';

final expenseProvider =
StateNotifierProvider<ExpenseNotifier, AsyncValue<List<ExpenseEntity>>>(
      (ref) => ExpenseNotifier(),
);

class ExpenseNotifier
    extends StateNotifier<AsyncValue<List<ExpenseEntity>>> {
  final ExpenseRepositoryImpl _repo = ExpenseRepositoryImpl();

  ExpenseNotifier() : super(const AsyncValue.loading());

  
  // LOAD ALL EXPENSES FOR A USER
  
  Future<void> loadExpensesForUser(int userId) async {
    try {
      state = const AsyncValue.loading();
      final list = await _repo.getExpensesByUser(userId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }


  
  // SAVE RECEIPT FILE
  
  Future<String> _saveFileToAppDir(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final id = const Uuid().v4();
    final ext = file.path.split('.').last;

    final receiptsDir = Directory('${appDir.path}/receipts');
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    final newPath = '${receiptsDir.path}/receipt_$id.$ext';
    final newFile = await file.copy(newPath);
    return newFile.path;
  }

  
  // ADD EXPENSE
  
  Future<void> addExpense({
    required int userId,
    required double amount,
    required String category,
    required String date,
    String? merchant,
    String? description,
    File? receiptFile,
  }) async {
    try {
      String? savedPath;
      if (receiptFile != null) {
        savedPath = await _saveFileToAppDir(receiptFile);
      }

      final expense = ExpenseEntity(
        id: null,
        reportId: 0,
        userId: userId,
        amount: amount,
        category: category,
        date: date,
        merchant: merchant,
        description: description,
        receiptPath: savedPath,
      );

      await _repo.insertExpense(expense);

      //  ALWAYS reload ALL expenses for user
      await loadExpensesForUser(userId);
    } catch (e) {
      rethrow;
    }
  }
}
