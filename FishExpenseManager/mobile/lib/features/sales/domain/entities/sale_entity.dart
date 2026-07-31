class SaleEntity {
  final int? id;
  final String uuid;
  final int customerId;
  final double totalAmount;
  final double paidAmount;
  final double debtAmount;
  final DateTime saleDate;
  final DateTime createdAt;
  final List<SaleItemEntity> items;

  const SaleEntity({
    this.id,
    required this.uuid,
    required this.customerId,
    required this.totalAmount,
    required this.paidAmount,
    required this.debtAmount,
    required this.saleDate,
    required this.createdAt,
    required this.items,
  });
}

class SaleItemEntity {
  final int? id;
  final int productId;
  final double quantity;
  final double unitPrice;
  final double subTotal;

  const SaleItemEntity({
    this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
  });
}
