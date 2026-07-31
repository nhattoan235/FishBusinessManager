import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/dao/inventory_dao.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;
  final InventoryDao _dao;

  InventoryRepositoryImpl(this._db) : _dao = _db.inventoryDao;

  @override
  Stream<List<InventorySummaryEntity>> watchInventorySummary() {
    if (kIsWeb) {
      return Stream.value([
        InventorySummaryEntity(
          product: ProductEntity(id: 1, uuid: 'p1', categoryId: 1, unitId: 1, name: 'Chứng nước', isActive: true, createdAt: DateTime.now()),
          currentStock: 150,
        ),
      ]);
    }

    // Ledger pattern: Sum(quantity) grouped by product via reactive watch
    final query = _db.customSelect(
      '''
      SELECT p.id, p.uuid, p.category_id, p.unit_id, p.name, p.default_price, p.note, p.is_active, p.created_at,
             COALESCE(SUM(i.quantity), 0.0) AS current_stock
      FROM products p
      LEFT JOIN inventory_entries i ON p.id = i.product_id
      WHERE p.is_active = 1
      GROUP BY p.id
      ORDER BY p.name
      ''',
      readsFrom: {_db.products, _db.inventoryEntries},
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        final pCreatedAtRaw = row.data['created_at'];
        DateTime pCreatedAt;
        if (pCreatedAtRaw is int) {
          pCreatedAt = DateTime.fromMillisecondsSinceEpoch(pCreatedAtRaw * 1000);
        } else if (pCreatedAtRaw is String) {
          pCreatedAt = DateTime.parse(pCreatedAtRaw);
        } else {
          pCreatedAt = DateTime.now();
        }

        final isActiveRaw = row.data['is_active'];
        final pIsActive = isActiveRaw == 1 || isActiveRaw == true;

        final currentStockRaw = row.data['current_stock'];
        final currentStock = (currentStockRaw as num?)?.toDouble() ?? 0.0;

        final product = ProductEntity(
          id: row.data['id'] as int,
          uuid: row.data['uuid'] as String,
          categoryId: row.data['category_id'] as int,
          unitId: row.data['unit_id'] as int,
          name: row.data['name'] as String,
          defaultPrice: row.data['default_price'] as int?,
          note: row.data['note'] as String?,
          isActive: pIsActive,
          createdAt: pCreatedAt,
        );

        return InventorySummaryEntity(
          product: product,
          currentStock: currentStock,
        );
      }).toList();
    });
  }

  @override
  Future<List<InventoryEntryEntity>> getInventoryHistory({int? limit, int? offset}) async {
    if (kIsWeb) return [];
    
    final query = _db.select(_db.inventoryEntries).join([
      innerJoin(_db.products, _db.products.id.equalsExp(_db.inventoryEntries.productId)),
    ])
      ..orderBy([OrderingTerm.desc(_db.inventoryEntries.createdAt)])
      ..limit(limit ?? 100, offset: offset);

    final rows = await query.get();
    return rows.map((row) {
      final entry = row.readTable(_db.inventoryEntries);
      final product = row.readTable(_db.products);

      return InventoryEntryEntity(
        id: entry.id,
        uuid: entry.uuid,
        productId: entry.productId,
        product: ProductEntity(
          id: product.id,
          uuid: product.uuid,
          categoryId: product.categoryId,
          unitId: product.unitId,
          name: product.name,
          defaultPrice: product.defaultPrice,
          isActive: product.isActive,
          createdAt: product.createdAt,
        ),
        entryType: entry.entryType,
        quantity: entry.quantity,
        note: entry.note,
        createdAt: entry.createdAt,
      );
    }).toList();
  }

  @override
  Future<void> adjustInventory({
    required int productId,
    required double difference,
    String? note,
  }) async {
    if (kIsWeb) return;
    
    await _dao.insertEntry(InventoryEntriesCompanion.insert(
      uuid: const Uuid().v4(),
      productId: productId,
      entryType: 'adjustment',
      quantity: difference,
      note: Value(note),
      createdAt: Value(DateTime.now()),
    ));
  }
}
