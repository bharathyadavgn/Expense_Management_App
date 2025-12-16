import '../../domain/entities/status_history_entity.dart';

class StatusHistoryModel extends StatusHistoryEntity {
  StatusHistoryModel({
    int? id,
    required int reportId,
    required String status,
    required int actorId,
    String? comment,
    required String timestamp,
  }) : super(
            id: id,
            reportId: reportId,
            status: status,
            actorId: actorId,
            comment: comment,
            timestamp: timestamp);

  factory StatusHistoryModel.fromMap(Map<String, dynamic> map) {
    return StatusHistoryModel(
      id: map['id'] as int?,
      reportId: map['report_id'] as int,
      status: map['status'] as String,
      actorId: map['actor_id'] as int,
      comment: map['comment'] as String?,
      timestamp: map['timestamp'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'status': status,
      'actor_id': actorId,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}
