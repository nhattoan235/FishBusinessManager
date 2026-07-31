class DebtItemEntity {
  final int customerId;
  final String customerName;
  final String? customerPhone;
  final double balance;
  final DateTime lastUpdatedAt;

  const DebtItemEntity({
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.balance,
    required this.lastUpdatedAt,
  });
}
