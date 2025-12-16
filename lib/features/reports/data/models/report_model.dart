import '../../domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  ReportModel({
    int? id,
    required String title,
    String? purpose,
    required int userId,
    required double totalAmount,
    required String status,
    String? submissionDate,
  }) : super(
            id: id,
            title: title,
            purpose: purpose,
            userId: userId,
            totalAmount: totalAmount,
            status: status,
            submissionDate: submissionDate);

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      purpose: map['purpose'] as String?,
      userId: map['user_id'] as int,
      totalAmount: (map['total_amount'] as num).toDouble(),
      status: map['status'] as String,
      submissionDate: map['submission_date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'purpose': purpose,
      'user_id': userId,
      'total_amount': totalAmount,
      'status': status,
      'submission_date': submissionDate,
    };
  }
}
