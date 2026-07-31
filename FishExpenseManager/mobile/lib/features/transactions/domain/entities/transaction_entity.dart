class TransactionEntity {
  final int? id;
  final String uuid;
  final double amount;
  final bool isIncome;
  final String type; // 'income' or 'expense'
  final String description;
  final DateTime date;
  final String? referenceId;
  final DateTime createdAt;

  const TransactionEntity({
    this.id,
    required this.uuid,
    required this.amount,
    required this.isIncome,
    required this.type,
    required this.description,
    required this.date,
    this.referenceId,
    required this.createdAt,
  });
}
