class ReportEntity {
  final int? id;
  final String title;
  final String? purpose;
  final int userId;
  final double totalAmount;
  final String status;
  final String? submissionDate;

  ReportEntity({
    this.id,
    required this.title,
    this.purpose,
    required this.userId,
    required this.totalAmount,
    required this.status,
    this.submissionDate,
  });
}
