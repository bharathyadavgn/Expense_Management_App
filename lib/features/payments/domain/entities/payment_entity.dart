class PaymentEntity {
  final int? id;
  final int reportId;
  final int financeUserId;
  final String? transactionId;
  final double amount;
  final String? date;
  final String status;

  PaymentEntity({
    this.id,
    required this.reportId,
    required this.financeUserId,
    this.transactionId,
    required this.amount,
    this.date,
    required this.status,
  });
}
