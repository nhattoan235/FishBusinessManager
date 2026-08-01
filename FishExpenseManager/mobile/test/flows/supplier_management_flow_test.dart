// ignore_for_file: avoid_print
import 'package:matcher/matcher.dart' as m;
import 'package:drift/drift.dart';
import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/suppliers/application/supplier_provider.dart';
import 'package:fish_business_manager/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:uuid/uuid.dart';

import '../utils/test_utils.dart';

void main() {
  group('Supplier Management Flow Tests — UC-020 Quản lý Nhà cung cấp', () {
    // ─── Thêm Nhà cung cấp ────────────────────────────────────────────────────

    test('Thêm nhà cung cấp mới thành công (BR-201)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final supplierRepo = container.read(supplierRepositoryProvider);

      await supplierRepo.saveSupplier(
        SupplierEntity(
          uuid: 'sup-uuid-001',
          name: 'Công ty Chứng Nước Miền Nam',
          phone: '02812345678',
          address: '456 Đường XYZ',
          note: 'Nhà cung cấp chính',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      final suppliers = await supplierRepo.getAllSuppliers();
      final found = suppliers.firstWhere((s) => s.uuid == 'sup-uuid-001');
      expect(found.name, 'Công ty Chứng Nước Miền Nam');
      expect(found.isActive, true,
          reason: 'Nhà cung cấp mới phải ở trạng thái active');
    });

    test('Thêm nhà cung cấp - Chỉ cần tên, các trường khác tùy chọn (BR-201)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final supplierRepo = container.read(supplierRepositoryProvider);

      await supplierRepo.saveSupplier(
        SupplierEntity(
          uuid: 'sup-uuid-002',
          name: 'Người bán lẻ A',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      final suppliers = await supplierRepo.getAllSuppliers();
      final found = suppliers.firstWhere((s) => s.uuid == 'sup-uuid-002');
      expect(found.name, 'Người bán lẻ A');
      expect(found.phone, m.isNull,
          reason: 'Số điện thoại không bắt buộc');
      expect(found.address, m.isNull,
          reason: 'Địa chỉ không bắt buộc');
    });

    // ─── Sửa thông tin Nhà cung cấp ──────────────────────────────────────────

    test('Sửa thông tin nhà cung cấp thành công (BR-203)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final supplierRepo = container.read(supplierRepositoryProvider);

      await supplierRepo.saveSupplier(
        SupplierEntity(
          uuid: 'sup-uuid-003',
          name: 'Tên cũ NCC',
          phone: '0900000000',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      final suppliers = await supplierRepo.getAllSuppliers();
      final existing = suppliers.firstWhere((s) => s.uuid == 'sup-uuid-003');

      // Sửa tên và số điện thoại
      await supplierRepo.saveSupplier(
        SupplierEntity(
          id: existing.id,
          uuid: existing.uuid,
          name: 'Tên mới NCC đã cập nhật',
          phone: '0988888888',
          address: 'Địa chỉ mới',
          note: existing.note,
          isActive: existing.isActive,
          createdAt: existing.createdAt,
        ),
      );

      final updated = await supplierRepo.getAllSuppliers();
      final updatedSupplier =
          updated.firstWhere((s) => s.uuid == 'sup-uuid-003');
      expect(updatedSupplier.name, 'Tên mới NCC đã cập nhật',
          reason: 'Có thể sửa tên bất kỳ lúc nào (BR-203)');
      expect(updatedSupplier.phone, '0988888888');
    });

    // ─── Khóa / Xóa Nhà cung cấp ─────────────────────────────────────────────

    test(
        'Khóa nhà cung cấp đã có lịch sử nhập kho - Không xóa vật lý (BR-202)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final supplierRepo = container.read(supplierRepositoryProvider);
      final db = container.read(databaseProvider);

      // Tạo nhà cung cấp
      await supplierRepo.saveSupplier(
        SupplierEntity(
          uuid: 'sup-uuid-004',
          name: 'NCC có lịch sử nhập hàng',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
      final suppliers = await supplierRepo.getAllSuppliers();
      final supplier = suppliers.firstWhere((s) => s.uuid == 'sup-uuid-004');

      // Ghi nhận nhập kho liên kết nhà cung cấp này
      await db.inventoryDao.insertEntry(
        InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: 1,
          entryType: 'purchase',
          quantity: 100,
          supplierId: Value(supplier.id!),
          note: const Value('Nhập từ NCC này'),
          createdAt: Value(DateTime.now()),
        ),
      );

      // Xóa mềm nhà cung cấp
      await supplierRepo.deleteSupplier(supplier.id!);

      // Nhà cung cấp vẫn tồn tại trong DB (soft delete - lịch sử kho còn đó)
      final rawData = await (db.select(db.suppliers)
            ..where((t) => t.id.equals(supplier.id!)))
          .getSingleOrNull();
      expect(rawData, m.isNotNull,
          reason:
              'Soft delete không xóa vật lý khi đã từng nhập hàng (BR-202)');
      // deletedAt hoặc isActive = false phải được set
      expect(rawData!.deletedAt != null || !rawData.isActive, true,
          reason: 'NCC bị khóa/xóa mềm sau khi deleteSupplier');
    });

    test('Xóa mềm nhà cung cấp chưa có lịch sử nhập kho', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final supplierRepo = container.read(supplierRepositoryProvider);
      final db = container.read(databaseProvider);

      await supplierRepo.saveSupplier(
        SupplierEntity(
          uuid: 'sup-uuid-005',
          name: 'NCC chưa từng nhập hàng',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
      final suppliers = await supplierRepo.getAllSuppliers();
      final supplier = suppliers.firstWhere((s) => s.uuid == 'sup-uuid-005');

      // Xóa mềm
      await supplierRepo.deleteSupplier(supplier.id!);

      final rawData = await (db.select(db.suppliers)
            ..where((t) => t.id.equals(supplier.id!)))
          .getSingleOrNull();
      // Soft delete: record vẫn còn nhưng deletedAt được set
      if (rawData != null) {
        expect(rawData.deletedAt, m.isNotNull,
            reason: 'deletedAt phải được set khi xóa mềm');
      }
    });
  });
}
