import 'package:expense_management_app/core/database/db_helper.dart';

import '../models/report_model.dart';

class ReportDao {
  final dbProvider = DBHelper.database;

  Future<int> insertReport(ReportModel report) async {
    final db = await dbProvider;
    return await db.insert('reports', report.toMap());
  }

  Future<void> updateReport(ReportModel report) async {
    final db = await dbProvider;
    await db.update('reports', report.toMap(),
        where: 'id = ?', whereArgs: [report.id]);
  }

  Future<ReportModel?> getReportById(int id) async {
    final db = await dbProvider;
    final maps = await db.query('reports', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return ReportModel.fromMap(maps.first);
    return null;
  }

  Future<List<ReportModel>> getReportsByUser(int userId) async {
    final db = await dbProvider;
    final maps = await db.query('reports',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'submission_date DESC');
    return maps.map((m) => ReportModel.fromMap(m)).toList();
  }

  Future<List<ReportModel>> getReportsByStatus(String status) async {
    final db = await dbProvider;
    final maps =
        await db.query('reports', where: 'status = ?', whereArgs: [status]);
    return maps.map((m) => ReportModel.fromMap(m)).toList();
  }
}
