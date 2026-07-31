/// Dữ liệu tổng hợp cho SCR-009 — Chi tiết sản phẩm
class ProductDetailData {
  final double currentStock;
  final List<InventoryEntryItem> inventoryEntries;
  final List<SaleHistoryItem> saleHistory;

  const ProductDetailData({
    required this.currentStock,
    required this.inventoryEntries,
    required this.saleHistory,
  });
}

class InventoryEntryItem {
  final String entryType; // purchase / harvest / sale / adjustment
  final double quantity;
  final String? note;
  final DateTime createdAt;

  const InventoryEntryItem({
    required this.entryType,
    required this.quantity,
    this.note,
    required this.createdAt,
  });

  String get typeLabel {
    switch (entryType) {
      case 'purchase': return 'Nhập hàng';
      case 'harvest': return 'Thu hoạch';
      case 'sale': return 'Bán ra';
      case 'adjustment': return 'Điều chỉnh';
      default: return entryType;
    }
  }
}

class SaleHistoryItem {
  final String customerName;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime saleDate;

  const SaleHistoryItem({
    required this.customerName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.saleDate,
  });
}
