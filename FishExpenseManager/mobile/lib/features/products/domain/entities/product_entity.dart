class ProductCategoryEntity {
  final int id;
  final String uuid;
  final String name;

  const ProductCategoryEntity({
    required this.id,
    required this.uuid,
    required this.name,
  });
}

class UnitEntity {
  final int id;
  final String uuid;
  final String name;
  final String symbol;

  const UnitEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.symbol,
  });
}

class ProductEntity {
  final int? id;
  final String uuid;
  final int categoryId;
  final ProductCategoryEntity? category;
  final int unitId;
  final UnitEntity? unit;
  final String name;
  final int? defaultPrice;
  final String? note;
  final bool isActive;
  final DateTime createdAt;
  final double? currentStock; // Tổng tồn kho hiện tại (tính từ inventory_entries)

  const ProductEntity({
    this.id,
    required this.uuid,
    required this.categoryId,
    this.category,
    required this.unitId,
    this.unit,
    required this.name,
    this.defaultPrice,
    this.note,
    required this.isActive,
    required this.createdAt,
    this.currentStock,
  });
}
