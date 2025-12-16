import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  PaymentModel({
    int? id,
    required int reportId,
    required int financeUserId,
    String? transactionId,
    required double amount,
    String? date,
    required String status,
  }) : super(
            id: id,
            reportId: reportId,
            financeUserId: financeUserId,
            transactionId: transactionId,
            amount: amount,
            date: date,
            status: status);

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as int?,
      reportId: map['report_id'] as int,
      financeUserId: map['finance_user_id'] as int,
      transactionId: map['transaction_id'] as String?,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String?,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'finance_user_id': financeUserId,
      'transaction_id': transactionId,
      'amount': amount,
      'date': date,
      'status': status,
    };
  }
}
