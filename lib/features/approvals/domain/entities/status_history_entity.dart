class StatusHistoryEntity {
  final int? id;
  final int reportId;
  final String status;
  final int actorId;
  final String? comment;
  final String timestamp;

  StatusHistoryEntity({
    this.id,
    required this.reportId,
    required this.status,
    required this.actorId,
    this.comment,
    required this.timestamp,
  });
}
