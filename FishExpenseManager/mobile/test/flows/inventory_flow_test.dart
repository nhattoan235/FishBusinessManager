import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/inventory/application/inventory_provider.dart';
import '../utils/test_utils.dart';

void main() {
  group('Inventory Flow Tests', () {
    test('Ledger Pattern - Tính tổng tồn kho chính xác (BR-801, BR-802)', () async {
      final container = createTestProviderContainer();
      final inventoryRepo = container.read(inventoryRepositoryProvider);

      // Theo DB003 và BR-801: Không update tồn kho trực tiếp, chỉ thêm các biến động.
      // 1. Nhập kho lần 1 (100)
      await inventoryRepo.adjustInventory(
        productId: 1, // Sản phẩm mặc định (Chứng nước) sinh ra từ db seed
        difference: 100,
        note: 'Nhập đầu ngày',
      );

      // 2. Kiểm tra tồn kho (100)
      var inventorySummary = await inventoryRepo.watchInventorySummary().first;
      var productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 100);

      // 3. Xuất kho (âm 20)
      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: -20,
        note: 'Xuất hàng hỏng',
      );

      // 4. Kiểm tra tồn kho (80)
      inventorySummary = await inventoryRepo.watchInventorySummary().first;
      productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 80);

      // 5. Kiểm tra lịch sử biến động kho
      final history = await inventoryRepo.getInventoryHistory();
      expect(history.length, 2);
      final quantities = history.map((e) => e.quantity).toList();
      expect(quantities.contains(-20), isTrue);
      expect(quantities.contains(100), isTrue);
    });
  });
}
