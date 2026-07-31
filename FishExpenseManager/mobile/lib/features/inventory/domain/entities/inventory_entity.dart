import '../../../products/domain/entities/product_entity.dart';

class InventoryEntryEntity {
  final int id;
  final String uuid;
  final int productId;
  final ProductEntity? product;
  final String entryType; // purchase / harvest / sale / adjustment
  final double quantity; // Positive for in, negative for out
  final String? note;
  final DateTime createdAt;

  const InventoryEntryEntity({
    required this.id,
    required this.uuid,
    required this.productId,
    this.product,
    required this.entryType,
    required this.quantity,
    this.note,
    required this.createdAt,
  });
}

class InventorySummaryEntity {
  final ProductEntity product;
  final double currentStock;

  const InventorySummaryEntity({
    required this.product,
    required this.currentStock,
  });
}
