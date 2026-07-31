import '../entities/inventory_entity.dart';

abstract class InventoryRepository {
  /// Returns the current stock for each active product
  Stream<List<InventorySummaryEntity>> watchInventorySummary();
  
  /// Returns the history of entries (paginated or full)
  Future<List<InventoryEntryEntity>> getInventoryHistory({int? limit, int? offset});
  
  /// Adjusts the inventory by creating a new adjustment entry
  Future<void> adjustInventory({
    required int productId,
    required double difference,
    String? note,
  });
}
