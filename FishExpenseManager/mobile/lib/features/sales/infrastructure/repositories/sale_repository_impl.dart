import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/dao/sale_dao.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sale_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class SaleRepositoryImpl implements SaleRepository {
  final AppDatabase _db;
  final SaleDao _saleDao;

  SaleRepositoryImpl(this._db) : _saleDao = _db.saleDao;

  @override
  Future<void> createSale(SaleEntity sale) async {
    if (kIsWeb) return;
    
    await _db.transaction(() async {
      // 1. Create Sale Document
      // DB stores amounts as int (đồng), entity uses double
      final saleDocId = await _saleDao.insertSaleDocument(SaleDocumentsCompanion.insert(
        uuid: sale.uuid,
        customerId: sale.customerId,
        totalAmount: sale.totalAmount.toInt(),
        paidAmount: sale.paidAmount.toInt(),
        debtAmount: sale.debtAmount.toInt(),
        saleDate: sale.saleDate,
        createdAt: Value(sale.createdAt),
      ));

      // 2. Insert Sale Items and deduct inventory
      final saleItemCompanions = sale.items.map((item) => SaleItemsCompanion.insert(
        saleDocumentId: saleDocId,
        productId: item.productId,
        quantity: item.quantity,
        unitPrice: item.unitPrice.toInt(),
        totalPrice: item.subTotal.toInt(),
      )).toList();
      await _saleDao.insertSaleItems(saleItemCompanions);

      // 3. Deduct inventory for each item
      for (final item in sale.items) {
        await _db.inventoryDao.insertEntry(InventoryEntriesCompanion.insert(
          uuid: const Uuid().v4(),
          productId: item.productId,
          entryType: 'sale',
          quantity: -item.quantity, // Negative for sale (deduction)
          saleDocumentId: Value(saleDocId),
          createdAt: Value(DateTime.now()),
        ));
      }

      // 4. Record income if paidAmount > 0
      if (sale.paidAmount > 0) {
        await _db.transactionDao.insertTransaction(TransactionsCompanion.insert(
          uuid: const Uuid().v4(),
          amount: sale.paidAmount.toInt(),
          isIncome: const Value(true),
          type: 'Bán hàng',
          description: const Value('Thu tiền bán hàng'),
          date: sale.saleDate,
          referenceId: Value(sale.uuid),
          createdAt: Value(DateTime.now()),
        ));
      }

      // 5. Record debt if debtAmount > 0
      if (sale.debtAmount > 0) {
        // Upsert customer balance
        final existingBalances = await (_db.select(_db.customerBalances)
          ..where((t) => t.customerId.equals(sale.customerId))).get();

        if (existingBalances.isEmpty) {
          await _db.into(_db.customerBalances).insert(CustomerBalancesCompanion.insert(
            customerId: Value(sale.customerId),
            currentDebt: Value(sale.debtAmount.toInt()),
            updatedAt: Value(DateTime.now()),
          ));
        } else {
          final current = existingBalances.first;
          await (_db.update(_db.customerBalances)
            ..where((t) => t.customerId.equals(sale.customerId))).write(CustomerBalancesCompanion(
            currentDebt: Value(current.currentDebt + sale.debtAmount.toInt()),
            updatedAt: Value(DateTime.now()),
          ));
        }

        // Record debt transaction
        await _db.debtDao.insertDebtTransaction(DebtTransactionsCompanion.insert(
          customerId: sale.customerId,
          saleDocumentId: Value(saleDocId),
          changeType: 'increase',
          amount: sale.debtAmount.toInt(),
          note: const Value('Ghi nợ bán hàng'),
          createdAt: Value(DateTime.now()),
        ));
      }
    });
  }
}
