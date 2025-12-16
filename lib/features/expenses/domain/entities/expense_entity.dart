class ExpenseEntity {
  final int? id;
  final int reportId;
  final int userId;
  final double amount;
  final String category;
  final String date;
  final String? merchant;
  final String? description;
  final String? receiptPath;

  ExpenseEntity({
    this.id,
    required this.reportId,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    this.merchant,
    this.description,
    this.receiptPath,
  });
}
