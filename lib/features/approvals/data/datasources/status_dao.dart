import '../../../../core/database/db_helper.dart';
import '../models/status_history_model.dart';

class StatusDao {
  final dbProvider = DBHelper.database;

  Future<int> insertStatus(StatusHistoryModel status) async {
    final db = await dbProvider;
    return await db.insert('report_status_history', status.toMap());
  }

  Future<List<StatusHistoryModel>> getStatusHistoryForReport(
      int reportId) async {
    final db = await dbProvider;
    final maps = await db.query('report_status_history',
        where: 'report_id = ?',
        whereArgs: [reportId],
        orderBy: 'timestamp DESC');
    return maps.map((m) => StatusHistoryModel.fromMap(m)).toList();
  }
}
