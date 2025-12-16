import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/db_helper.dart';
import '../features/reports/domain/entities/report_entity.dart';
import '../features/reports/data/models/report_model.dart';

final reportProvider =
StateNotifierProvider<ReportNotifier, AsyncValue<List<ReportEntity>>>(
      (ref) => ReportNotifier(),
);

class ReportNotifier extends StateNotifier<AsyncValue<List<ReportEntity>>> {
  ReportNotifier() : super(const AsyncValue.loading()) {
    loadReports();
    
// FINANCE — GET PENDING PAYMENT REPORTS

    Future<List<Map<String, Object?>>> getPendingPaymentReports() async {
      final db = await DBHelper.database;

      return await db.query(
        'reports',
        where: 'status = ?',
        whereArgs: ['Pending Payment'],
        orderBy: 'submission_date DESC',
      );
    }

  }

   
  // CORE LOADER
   
  Future<void> loadReports() async {
    try {
      final db = await DBHelper.database;
      final rows =
      await db.query('reports', orderBy: 'submission_date DESC');

      final list = rows
          .map((e) => ReportModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

   
  // CREATE REPORT (DRAFT)
   
  Future<int> createReport({
    required String title,
    String? purpose,
    required int userId,
  }) async {
    final db = await DBHelper.database;

    final id = await db.insert('reports', {
      'title': title,
      'purpose': purpose,
      'user_id': userId,
      'total_amount': 0,
      'status': 'Draft',
      'submission_date': null,
    });

    await loadReports();
    return id;
  }

  


  Future<Map<String, Object?>> getReportById(int reportId) async {
    final db = await DBHelper.database;
    final rows =
    await db.query('reports', where: 'id = ?', whereArgs: [reportId]);
    return rows.first;
  }

  Future<List<Map<String, Object?>>> getReportExpenses(int reportId) async {
    final db = await DBHelper.database;
    return await db.query(
      'expenses',
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, Object?>>> getStatusHistory(int reportId) async {
    final db = await DBHelper.database;
    return await db.query(
      'report_status_history',
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'timestamp ASC',
    );
  }

  
// FINANCE — GET PENDING PAYMENT REPORTS

  Future<List<Map<String, Object?>>> getPendingPaymentReports() async {
    final db = await DBHelper.database;

    return await db.query(
      'reports',
      where: 'status = ?',
      whereArgs: ['Pending Payment'],
      orderBy: 'submission_date DESC',
    );
  }

  
// FINANCE — GET ALL PAYMENTS (HISTORY)

  Future<List<Map<String, Object?>>> getAllPayments() async {
    final db = await DBHelper.database;

    return await db.query(
      'payments',
      orderBy: 'date DESC',
    );
  }

  
// COMMON — LOAD REPORTS (used by dashboards & refresh)

  Future<void> loadReportsForUser(int? userId) async {
    try {
      state = const AsyncValue.loading();
      final db = await DBHelper.database;

      final rows = userId == null
          ? await db.query('reports', orderBy: 'submission_date DESC')
          : await db.query(
        'reports',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'submission_date DESC',
      );

      final list = rows
          .map((m) => ReportModel.fromMap(Map<String, dynamic>.from(m)))
          .toList();

      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }


   
  // ATTACH EXPENSES
   
  Future<void> attachExpensesToReport(
      int reportId, List<int> expenseIds) async {
    final db = await DBHelper.database;
    final batch = db.batch();

    for (final id in expenseIds) {
      batch.update(
        'expenses',
        {'report_id': reportId},
        where: 'id = ?',
        whereArgs: [id],
      );
    }


    await batch.commit(noResult: true);

    final sum = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE report_id = ?',
      [reportId],
    );

    final total = (sum.first['total'] as num?)?.toDouble() ?? 0;

    await db.update(
      'reports',
      {'total_amount': total},
      where: 'id = ?',
      whereArgs: [reportId],
    );

    await loadReports();
  }

   
  // SUBMIT REPORT
   
  Future<void> submitReport(
      int reportId,
      int actorId, {
        String? comment,
      }) async {
    final db = await DBHelper.database;
    final now = DateTime.now().toIso8601String();

    // Update report
    await db.update(
      'reports',
      {
        'status': 'Submitted',
        'submission_date': now,
      },
      where: 'id = ?',
      whereArgs: [reportId],
    );


    await db.insert('report_status_history', {
      'report_id': reportId,
      'status': 'Submitted',
      'actor_id': actorId,
      'comment': comment,
      'timestamp': now,
    });

    await loadReports();
  }


   
  // MANAGER ACTIONS
   
  Future<void> approveReport(int reportId, int managerId,
      {String? comment}) async {
    final db = await DBHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'reports',
      {'status': 'Pending Payment'},
      where: 'id = ?',
      whereArgs: [reportId],
    );

    await db.insert('report_status_history', {
      'report_id': reportId,
      'status': 'Pending Payment',
      'actor_id': managerId,
      'comment': comment,
      'timestamp': now,
    });

    await loadReports();
  }

  Future<void> rejectReport(
      int reportId, int managerId, String comment) async {
    final db = await DBHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'reports',
      {'status': 'Rejected'},
      where: 'id = ?',
      whereArgs: [reportId],
    );

    await db.insert('report_status_history', {
      'report_id': reportId,
      'status': 'Rejected',
      'actor_id': managerId,
      'comment': comment,
      'timestamp': now,
    });

    await loadReports();
  }


  // FINANCE PAYMENT
  Future<void> processMockPayment(
      int reportId,
      int financeUserId,
      ) async {
    final db = await DBHelper.database;

    final internalTxn =
        'TXN_SYS_${DateTime.now().millisecondsSinceEpoch}';

    // simulate delay
    await Future.delayed(const Duration(seconds: 1));

    // get report amount
    final rows =
    await db.query('reports', where: 'id = ?', whereArgs: [reportId]);

    final total =
        (rows.first['total_amount'] as num?)?.toDouble() ?? 0;

    //  INSERT — MATCHES payments TABLE EXACTLY
    await db.insert('payments', {
      'report_id': reportId,
      'finance_user_id': financeUserId,
      'transaction_id': internalTxn,
      'amount': total,
      'date': DateTime.now().toIso8601String(),
      'status': 'Completed',
    });

    //  UPDATE REPORT STATUS
    await db.update(
      'reports',
      {'status': 'Paid'},
      where: 'id = ?',
      whereArgs: [reportId],
    );

    // refresh providers
    await loadReports();
  }


// ANALYTICS — RAW REPORTS

  Future<List<Map<String, Object?>>> rawAllReports() async {
    final db = await DBHelper.database;
    return await db.query('reports');
  }

  
// ANALYTICS — ALL EXPENSES

  Future<List<Map<String, Object?>>> getAllExpenses() async {
    final db = await DBHelper.database;
    return await db.query('expenses');
  }

// ANALYTICS — USER MAP (id -> name)

  Future<Map<int, String>> getUserMap() async {
    final db = await DBHelper.database;
    final rows = await db.query('users');

    return {
      for (final r in rows)
        r['id'] as int: r['name'] as String,
    };
  }


}
