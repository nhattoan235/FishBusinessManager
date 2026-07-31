import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/product_detail_entity.dart';

class ProductDetailRepository {
  final AppDatabase _db;
  ProductDetailRepository(this._db);

  Future<ProductDetailData> getProductDetail(int productId) async {
    if (kIsWeb) return _getMockDetail(productId);

    // Tồn kho hiện tại
    final stockRows = await _db.customSelect(
      'SELECT COALESCE(SUM(quantity), 0.0) AS stock FROM inventory_entries WHERE product_id = ?',
      variables: [Variable.withInt(productId)],
      readsFrom: {_db.inventoryEntries},
    ).get();
    final currentStock = (stockRows.first.data['stock'] as num?)?.toDouble() ?? 0.0;

    // Lịch sử nhập kho (purchase + harvest + adjustment dương)
    final entryRows = await _db.customSelect(
      '''SELECT * FROM inventory_entries
         WHERE product_id = ? AND quantity > 0
         ORDER BY created_at DESC LIMIT 30''',
      variables: [Variable.withInt(productId)],
      readsFrom: {_db.inventoryEntries},
    ).get();

    // Lịch sử bán (sale_items với sale_documents)
    final saleRows = await _db.customSelect(
      '''
      SELECT si.quantity, si.unit_price, si.subtotal,
             sd.sale_date, c.name AS customer_name
      FROM sale_items si
      JOIN sale_documents sd ON sd.id = si.sale_document_id
      LEFT JOIN customers c ON c.id = sd.customer_id
      WHERE si.product_id = ?
      ORDER BY sd.sale_date DESC LIMIT 30
      ''',
      variables: [Variable.withInt(productId)],
      readsFrom: {_db.saleItems, _db.saleDocuments, _db.customers},
    ).get();

    final entries = entryRows.map((r) {
      final raw = r.data['created_at'];
      DateTime dt;
      if (raw is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      } else if (raw is String) {
        dt = DateTime.parse(raw);
      } else {
        dt = DateTime.now();
      }
      return InventoryEntryItem(
        entryType: r.data['entry_type'] as String,
        quantity: (r.data['quantity'] as num).toDouble(),
        note: r.data['note'] as String?,
        createdAt: dt,
      );
    }).toList();

    final sales = saleRows.map((r) {
      final raw = r.data['sale_date'];
      DateTime dt;
      if (raw is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      } else if (raw is String) {
        dt = DateTime.parse(raw);
      } else {
        dt = DateTime.now();
      }
      return SaleHistoryItem(
        customerName: r.data['customer_name'] as String? ?? 'Không rõ',
        quantity: (r.data['quantity'] as num).toDouble(),
        unitPrice: (r.data['unit_price'] as num).toDouble(),
        subtotal: (r.data['subtotal'] as num).toDouble(),
        saleDate: dt,
      );
    }).toList();

    return ProductDetailData(
      currentStock: currentStock,
      inventoryEntries: entries,
      saleHistory: sales,
    );
  }

  ProductDetailData _getMockDetail(int productId) {
    final now = DateTime.now();
    return ProductDetailData(
      currentStock: 320,
      inventoryEntries: [
        InventoryEntryItem(
          entryType: 'purchase',
          quantity: 200,
          note: 'Mua từ chú Tư',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        InventoryEntryItem(
          entryType: 'harvest',
          quantity: 150,
          note: 'Thu hoạch khu B',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
      ],
      saleHistory: [
        SaleHistoryItem(
          customerName: 'Anh Ba',
          quantity: 10,
          unitPrice: 25000,
          subtotal: 250000,
          saleDate: now.subtract(const Duration(days: 1)),
        ),
        SaleHistoryItem(
          customerName: 'Chị Lan',
          quantity: 20,
          unitPrice: 25000,
          subtotal: 500000,
          saleDate: now.subtract(const Duration(days: 3)),
        ),
      ],
    );
  }
}
