// ignore_for_file: avoid_print
import 'package:matcher/matcher.dart' as m;
import 'package:drift/drift.dart';
import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/products/application/product_provider.dart';
import 'package:fish_business_manager/features/products/domain/entities/product_entity.dart';
import 'package:uuid/uuid.dart';

import '../utils/test_utils.dart';

void main() {
  group('Product Management Flow Tests — UC-008/UC-009 Quản lý Sản phẩm', () {
    // ─── UC-008: Thêm Sản phẩm ────────────────────────────────────────────────

    test('Thêm sản phẩm mới thành công với đầy đủ thông tin (BR-301, BR-302)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final productRepo = container.read(productRepositoryProvider);

      // Lấy danh mục và đơn vị từ seed data
      final categories = await productRepo.getCategories();
      final units = await productRepo.getUnits();
      expect(categories.isNotEmpty, true, reason: 'Seed phải có danh mục');
      expect(units.isNotEmpty, true, reason: 'Seed phải có đơn vị');

      final category = categories.first;
      final unit = units.first;

      // Thêm sản phẩm mới
      await productRepo.saveProduct(
        ProductEntity(
          uuid: const Uuid().v4(),
          categoryId: category.id, // BR-301: thuộc đúng 1 danh mục
          unitId: unit.id, // BR-302: có đúng 1 đơn vị
          name: 'Cá Rô Phi Giống',
          defaultPrice: 8000,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      final products = await productRepo.getAllProducts();
      final found = products.firstWhere((p) => p.name == 'Cá Rô Phi Giống',
          orElse: () => throw Exception('Không tìm thấy sản phẩm'));
      expect(found.categoryId, category.id,
          reason: 'Sản phẩm phải thuộc đúng 1 danh mục (BR-301)');
      expect(found.unitId, unit.id,
          reason: 'Sản phẩm phải có đúng 1 đơn vị (BR-302)');
      expect(found.isActive, true,
          reason: 'Sản phẩm mới phải là active');
      expect(found.defaultPrice, 8000,
          reason: 'Giá bán mặc định phải được lưu');
    });

    test('Lấy danh sách danh mục sản phẩm từ seed data', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final productRepo = container.read(productRepositoryProvider);
      final categories = await productRepo.getCategories();

      expect(categories.isNotEmpty, true,
          reason: 'Seed data phải có danh mục sản phẩm');
      expect(categories.any((c) => c.name == 'Chứng nước'), true,
          reason: 'Seed phải có danh mục Chứng nước mặc định');
    });

    test('Lấy danh sách đơn vị tính từ seed data (BR-302)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final productRepo = container.read(productRepositoryProvider);
      final units = await productRepo.getUnits();

      expect(units.isNotEmpty, true, reason: 'Seed phải có đơn vị tính');
      expect(units.any((u) => u.symbol == 'kg'), true,
          reason: 'Seed phải có đơn vị kg mặc định');
    });

    // ─── UC-008: Sửa Sản phẩm ────────────────────────────────────────────────

    test('Sửa thông tin sản phẩm thành công (giá bán mặc định)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final productRepo = container.read(productRepositoryProvider);

      // Lấy sản phẩm Chứng nước từ seed
      final products = await productRepo.getAllProducts();
      final chungnuoc = products.firstWhere((p) => p.name == 'Chứng nước');

      // Sửa giá bán mặc định
      await productRepo.saveProduct(
        ProductEntity(
          id: chungnuoc.id,
          uuid: chungnuoc.uuid,
          categoryId: chungnuoc.categoryId,
          unitId: chungnuoc.unitId,
          name: chungnuoc.name,
          defaultPrice: 30000, // Cập nhật giá
          note: 'Giá cập nhật tháng 8',
          isActive: chungnuoc.isActive,
          createdAt: chungnuoc.createdAt,
        ),
      );

      final updated = await productRepo.getAllProducts();
      final updatedProduct =
          updated.firstWhere((p) => p.id == chungnuoc.id);
      expect(updatedProduct.defaultPrice, 30000,
          reason: 'Giá bán phải được cập nhật');
      expect(updatedProduct.note, 'Giá cập nhật tháng 8');
    });

    // ─── UC-008: Ngừng kinh doanh Sản phẩm ──────────────────────────────────

    test(
        'Ngừng kinh doanh sản phẩm đã có lịch sử - Chỉ khóa, không xóa (BR-303, BR-304)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final productRepo = container.read(productRepositoryProvider);

      // Ghi nhận lịch sử kho cho sản phẩm 1 (Chứng nước từ seed)
      await db.inventoryDao.insertEntry(
        InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: 1,
          entryType: 'purchase',
          quantity: 100,
          createdAt: Value(DateTime.now()),
        ),
      );

      // Ngừng kinh doanh (soft delete / deactivate)
      await productRepo.deleteProduct(1);

      // Sản phẩm vẫn còn trong DB (không xóa vật lý) - BR-304
      final rawData = await (db.select(db.products)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      expect(rawData, m.isNotNull,
          reason: 'Sản phẩm đã bán không được xóa vật lý (BR-304)');
      expect(rawData!.isActive, false,
          reason: 'Sản phẩm ngừng kinh doanh: is_active = false (BR-303)');
    });

    test(
        'Sản phẩm ngừng kinh doanh không xuất hiện trong danh sách active (BR-303)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final productRepo = container.read(productRepositoryProvider);

      // Seed đã có sản phẩm id=1 "Chứng nước", ngừng kinh doanh nó
      await productRepo.deleteProduct(1);

      // Danh sách sản phẩm active không có Chứng nước nữa
      final activeProducts = await productRepo.getAllProducts();
      expect(activeProducts.any((p) => p.id == 1), false,
          reason: 'Sản phẩm ngừng KD không xuất hiện trong danh sách (BR-303)');
    });

    // ─── UC-009: Tồn kho sản phẩm ────────────────────────────────────────────

    test('Tồn kho hiện tại được tính đúng từ Ledger (BR-801)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      final productRepo = container.read(productRepositoryProvider);

      // Nhập kho 200
      await db.inventoryDao.insertEntry(
        InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: 1,
          entryType: 'purchase',
          quantity: 200,
          createdAt: Value(DateTime.now()),
        ),
      );

      // Bán 30
      await db.inventoryDao.insertEntry(
        InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: 1,
          entryType: 'sale',
          quantity: -30,
          createdAt: Value(DateTime.now()),
        ),
      );

      // Tồn kho hiện tại = 170
      final products = await productRepo.getAllProducts();
      final product = products.firstWhere((p) => p.id == 1);
      expect(product.currentStock, 170,
          reason: '200 - 30 = 170, tồn kho tính từ Ledger');
    });
  });
}
