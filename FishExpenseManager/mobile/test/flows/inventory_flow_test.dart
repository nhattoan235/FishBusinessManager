// ignore_for_file: avoid_print
import 'package:matcher/matcher.dart' as m;
import 'package:drift/drift.dart';
import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/inventory/application/inventory_provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/test_utils.dart';

void main() {
  group('Inventory Flow Tests — UC-010A Nhập kho & UC-010B Điều chỉnh Tồn kho',
      () {
    // ─── UC-010A: Nhập kho (Ledger Pattern) ──────────────────────────────────

    test('Ledger Pattern - Tổng tồn kho tính từ nhiều biến động (BR-801)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final inventoryRepo = container.read(inventoryRepositoryProvider);

      // Nhập kho lần 1 (100kg)
      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 100,
        note: 'Nhập đầu ngày',
      );

      var inventorySummary = await inventoryRepo.watchInventorySummary().first;
      var productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 100,
          reason: 'Sau lần nhập 1: tồn kho = 100');

      // Xuất kho (âm 20)
      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: -20,
        note: 'Xuất hàng hỏng',
      );

      inventorySummary = await inventoryRepo.watchInventorySummary().first;
      productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 80,
          reason: '100 - 20 = 80 sau khi xuất');

      // Nhập lần 2 (50kg)
      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 50,
        note: 'Nhập bổ sung',
      );

      inventorySummary = await inventoryRepo.watchInventorySummary().first;
      productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 130,
          reason: '80 + 50 = 130 sau lần nhập 2');

      // Lịch sử có đúng 3 bản ghi
      final history = await inventoryRepo.getInventoryHistory();
      expect(history.length, 3,
          reason: 'Ledger: mỗi lần nhập/xuất = 1 bản ghi mới (BR-801)');
    });

    test('Nhập kho loại purchase (mua từ nhà cung cấp) - BR-803', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);

      // Tạo nhà cung cấp trước
      final supplierId = await db.supplierDao.insertSupplier(
        SuppliersCompanion.insert(
          uuid: const Uuid().v4(),
          name: 'Nhà cung cấp Test',
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Nhập kho loại 'purchase'
      await db.inventoryDao.insertEntry(
        InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: 1,
          entryType: 'purchase',
          quantity: 200,
          supplierId: Value(supplierId),
          note: const Value('Mua từ nhà cung cấp'),
          createdAt: Value(DateTime.now()),
        ),
      );

      // Tồn kho tăng đúng
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final inventorySummary = await inventoryRepo.watchInventorySummary().first;
      final productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 200,
          reason: 'Nhập purchase 200 → tồn kho = 200');

      // Kiểm tra entry_type đúng
      final history = await inventoryRepo.getInventoryHistory();
      expect(history.any((e) => e.entryType == 'purchase'), true,
          reason: 'Phải có bản ghi loại purchase (BR-803)');
    });

    test('Nhập kho loại harvest (thu hoạch từ khu nuôi) - BR-803', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);

      // Nhập kho loại 'harvest'
      await db.inventoryDao.insertEntry(
        InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: 1,
          entryType: 'harvest',
          quantity: 150,
          note: const Value('Thu hoạch buổi sáng'),
          createdAt: Value(DateTime.now()),
        ),
      );

      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final inventorySummary = await inventoryRepo.watchInventorySummary().first;
      final productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 150,
          reason: 'Thu hoạch 150 → tồn kho = 150');

      final history = await inventoryRepo.getInventoryHistory();
      expect(history.any((e) => e.entryType == 'harvest'), true,
          reason: 'Phải có bản ghi loại harvest (BR-803)');
    });

    // ─── UC-010B: Điều chỉnh Tồn kho ─────────────────────────────────────────

    test('Điều chỉnh tăng kho (adjustment_increase) - BR-801', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);

      // Nhập ban đầu 50
      await inventoryRepo.adjustInventory(productId: 1, difference: 50);

      // Điều chỉnh tăng thêm 30
      await db.inventoryDao.insertEntry(
        InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: 1,
          entryType: 'adjustment',
          quantity: 30, // Positive = tăng
          note: const Value('Kiểm kê thừa'),
          createdAt: Value(DateTime.now()),
        ),
      );

      final inventorySummary = await inventoryRepo.watchInventorySummary().first;
      final productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 80,
          reason: '50 + 30 = 80 sau điều chỉnh tăng');
    });

    test('Điều chỉnh giảm kho (adjustment_decrease) - BR-801', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);

      // Nhập ban đầu 100
      await inventoryRepo.adjustInventory(productId: 1, difference: 100);

      // Điều chỉnh giảm 15 (hao hụt)
      await db.inventoryDao.insertEntry(
        InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: 1,
          entryType: 'adjustment',
          quantity: -15, // Negative = giảm
          note: const Value('Hao hụt trong ngày'),
          createdAt: Value(DateTime.now()),
        ),
      );

      final inventorySummary = await inventoryRepo.watchInventorySummary().first;
      final productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 85,
          reason: '100 - 15 = 85 sau điều chỉnh giảm');
    });

    test('Điều chỉnh giảm vượt tồn kho - Không cho phép tồn kho âm (BR-802)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final inventoryRepo = container.read(inventoryRepositoryProvider);

      // Tồn kho chỉ có 10
      await inventoryRepo.adjustInventory(productId: 1, difference: 10);

      // Điều chỉnh giảm 20 → tồn kho sẽ âm → phải lỗi (BR-802)
      await expectLater(
        inventoryRepo.adjustInventory(
          productId: 1,
          difference: -20, // Sẽ làm tồn kho -10 → Vi phạm BR-802
        ),
        throwsException,
      );

      // Tồn kho vẫn phải là 10
      final inventorySummary = await inventoryRepo.watchInventorySummary().first;
      final productStock = inventorySummary.firstWhere((e) => e.product.id == 1);
      expect(productStock.currentStock, 10,
          reason: 'Tồn kho không được âm, phải giữ nguyên 10 (BR-802)');
    });

    test('Lịch sử kho ghi đầy đủ thông tin (BR-804)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final inventoryRepo = container.read(inventoryRepositoryProvider);

      await inventoryRepo.adjustInventory(
        productId: 1,
        difference: 100,
        note: 'Kiểm tra lịch sử kho BR-804',
      );

      final history = await inventoryRepo.getInventoryHistory();
      expect(history.isNotEmpty, true);

      final entry = history.first;
      expect(entry.productId, 1, reason: 'Phải ghi đúng sản phẩm (BR-804)');
      expect(entry.quantity, 100,
          reason: 'Phải ghi đúng số lượng (BR-804)');
      expect(entry.entryType, isNotEmpty,
          reason: 'Phải ghi loại biến động (BR-804)');
      expect(entry.createdAt, m.isNotNull,
          reason: 'Phải ghi thời gian (BR-804)');
    });
  });
}
