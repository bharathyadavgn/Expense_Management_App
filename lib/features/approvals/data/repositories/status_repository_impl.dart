import '../../domain/entities/status_history_entity.dart';
import '../../domain/repositories/status_repository.dart';
import '../datasources/status_dao.dart';
import '../models/status_history_model.dart';

class StatusRepositoryImpl implements StatusRepository {
  final StatusDao _dao = StatusDao();

  @override
  Future<int> insertStatus(StatusHistoryEntity status) async {
    final model = StatusHistoryModel(
      id: status.id,
      reportId: status.reportId,
      status: status.status,
      actorId: status.actorId,
      comment: status.comment,
      timestamp: status.timestamp,
    );
    return await _dao.insertStatus(model);
  }

  @override
  Future<List<StatusHistoryEntity>> getStatusHistoryForReport(
      int reportId) async {
    return await _dao.getStatusHistoryForReport(reportId);
  }
}
