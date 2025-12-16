import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  ExpenseModel({
    int? id,
    required int reportId,
    required int userId,
    required double amount,
    required String category,
    required String date,
    String? merchant,
    String? description,
    String? receiptPath,
  }) : super(
            id: id,
            reportId: reportId,
            userId: userId,
            amount: amount,
            category: category,
            date: date,
            merchant: merchant,
            description: description,
            receiptPath: receiptPath);

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      reportId: map['report_id'] as int,
      userId: map['user_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: map['date'] as String,
      merchant: map['merchant'] as String?,
      description: map['description'] as String?,
      receiptPath: map['receipt_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'user_id': userId,
      'amount': amount,
      'category': category,
      'date': date,
      'merchant': merchant,
      'description': description,
      'receipt_path': receiptPath,
    };
  }
}
