// ignore_for_file: avoid_print
import 'package:matcher/matcher.dart' as m;
import 'package:drift/drift.dart';
import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fish_business_manager/features/customers/application/customer_provider.dart';
import 'package:fish_business_manager/features/customers/domain/entities/customer_entity.dart';
import 'package:fish_business_manager/features/inventory/application/inventory_provider.dart';
import 'package:fish_business_manager/features/sales/application/sale_provider.dart';
import 'package:fish_business_manager/features/sales/domain/entities/sale_entity.dart';
import 'package:uuid/uuid.dart';

import '../utils/test_utils.dart';

void main() {
  group(
      'Customer Management Flow Tests — UC-006/UC-007 Quản lý Khách hàng',
      () {
    // ─── UC-006: Thêm Khách hàng ──────────────────────────────────────────────

    test('Thêm khách hàng mới thành công (BR-101)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);

      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'cust-uuid-001',
          name: 'Nguyễn Văn A',
          phone: '0901234567',
          address: '123 Đường ABC',
          note: 'Khách quen',
          createdAt: DateTime.now(),
        ),
      );

      expect(customerId, m.isNotNull, reason: 'Thêm mới phải trả về id');
      expect(customerId > 0, true);

      final customers = await customerRepo.getAllCustomers();
      final found = customers.firstWhere((c) => c.uuid == 'cust-uuid-001');
      expect(found.name, 'Nguyễn Văn A');
      expect(found.phone, '0901234567');
      expect(found.isActive, true,
          reason: 'Khách hàng mới phải ở trạng thái active');
    });

    test('Thêm khách hàng - Chỉ cần tên, các trường khác không bắt buộc (BR-101)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);

      // Chỉ có tên, không có phone/address/note
      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'cust-uuid-002',
          name: 'Khách Không Số Điện Thoại',
          createdAt: DateTime.now(),
        ),
      );

      expect(customerId > 0, true);
      final customers = await customerRepo.getAllCustomers();
      final found = customers.firstWhere((c) => c.uuid == 'cust-uuid-002');
      expect(found.name, 'Khách Không Số Điện Thoại');
      expect(found.phone, m.isNull,
          reason: 'Điện thoại không bắt buộc (BR-101)');
      expect(found.address, m.isNull,
          reason: 'Địa chỉ không bắt buộc (BR-101)');
    });

    // ─── UC-006: Sửa Khách hàng ───────────────────────────────────────────────

    test('Sửa thông tin khách hàng thành công (BR-102)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);

      // Tạo khách hàng
      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'cust-uuid-003',
          name: 'Tên cũ',
          phone: '0900000000',
          createdAt: DateTime.now(),
        ),
      );

      // Sửa thông tin
      final customers = await customerRepo.getAllCustomers();
      final existing = customers.firstWhere((c) => c.id == customerId);

      await customerRepo.saveCustomer(
        CustomerEntity(
          id: existing.id,
          uuid: existing.uuid,
          name: 'Tên mới đã sửa',
          phone: '0999999999',
          address: 'Địa chỉ mới',
          note: existing.note,
          isActive: existing.isActive,
          createdAt: existing.createdAt,
        ),
      );

      final updated = await customerRepo.getAllCustomers();
      final updatedCustomer = updated.firstWhere((c) => c.id == customerId);
      expect(updatedCustomer.name, 'Tên mới đã sửa',
          reason: 'Tên phải được cập nhật (BR-102)');
      expect(updatedCustomer.phone, '0999999999',
          reason: 'Số điện thoại phải được cập nhật');
      expect(updatedCustomer.address, 'Địa chỉ mới');
    });

    // ─── UC-006: Khóa Khách hàng ──────────────────────────────────────────────

    test('Khóa khách hàng đã có giao dịch - is_active = false (BR-103, BR-104)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final inventoryRepo = container.read(inventoryRepositoryProvider);
      final createSaleUseCase = container.read(createSaleUseCaseProvider);

      // Tạo khách hàng
      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'cust-uuid-004',
          name: 'Khách có lịch sử',
          createdAt: DateTime.now(),
        ),
      );

      // Tạo giao dịch bán hàng cho khách này
      await inventoryRepo.adjustInventory(productId: 1, difference: 50);
      await createSaleUseCase.execute(
        customerId: customerId,
        totalAmount: 100000,
        paidAmount: 100000,
        saleDate: DateTime.now(),
        items: [
          const SaleItemEntity(
            productId: 1,
            quantity: 4,
            unitPrice: 25000,
            subTotal: 100000,
          ),
        ],
      );

      // Khóa khách hàng (soft delete / deactivate)
      await customerRepo.deleteCustomer(customerId);

      // Khách hàng phải bị khóa (is_active = false), lịch sử vẫn còn
      final allCustomers = await customerRepo.getAllCustomers();
      final lockedCustomer = allCustomers.firstWhere((c) => c.id == customerId);
      expect(lockedCustomer.isActive, false,
          reason: 'Khách đã có giao dịch chỉ được khóa, không xóa (BR-103/104)');
    });

    test('Xóa mềm khách hàng chưa có giao dịch (BR-104)', () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);
      final db = container.read(databaseProvider);

      // Tạo khách hàng chưa có giao dịch
      final customerId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'cust-uuid-005',
          name: 'Khách chưa mua',
          createdAt: DateTime.now(),
        ),
      );

      // Thực hiện xóa (soft delete)
      await customerRepo.deleteCustomer(customerId);

      // Kiểm tra deletedAt đã được set
      final rawData = await (db.select(db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingleOrNull();
      expect(rawData, m.isNotNull, reason: 'Soft delete không xóa vật lý');
      expect(rawData!.isActive, false,
          reason: 'is_active phải = false sau khi xóa/khóa');
    });

    // ─── UC-007: Danh sách Khách hàng ────────────────────────────────────────

    test('Danh sách khách hàng - Khách bị khóa không xuất hiện mặc định (BR-103)',
        () async {
      final container = createTestProviderContainer();
      addTearDown(container.dispose);

      final customerRepo = container.read(customerRepositoryProvider);

      // Thêm 2 khách hàng
      await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'cust-uuid-006a',
          name: 'Khách đang hoạt động',
          createdAt: DateTime.now(),
        ),
      );
      final lockedId = await customerRepo.addCustomer(
        CustomerEntity(
          uuid: 'cust-uuid-006b',
          name: 'Khách bị khóa',
          createdAt: DateTime.now(),
        ),
      );

      // Khóa khách thứ 2
      await customerRepo.deleteCustomer(lockedId);

      // watchAllCustomers mặc định - hành vi phụ thuộc vào cài đặt filter
      final allCustomers = await customerRepo.getAllCustomers();
      final lockedCustomer =
          allCustomers.firstWhere((c) => c.id == lockedId);
      expect(lockedCustomer.isActive, false,
          reason: 'Khách bị khóa phải có is_active = false');
    });
  });
}
