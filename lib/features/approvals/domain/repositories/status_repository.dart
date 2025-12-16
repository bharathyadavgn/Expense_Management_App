import '../entities/status_history_entity.dart';

abstract class StatusRepository {
  Future<int> insertStatus(StatusHistoryEntity status);

  Future<List<StatusHistoryEntity>> getStatusHistoryForReport(int reportId);
}
