import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/dao/product_dao.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;
  final ProductDao _dao;

  ProductRepositoryImpl(this._db) : _dao = _db.productDao;

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    if (kIsWeb) return _getMockProducts();
    return _fetchWithStock();
  }

  @override
  Stream<List<ProductEntity>> watchAllProducts() {
    if (kIsWeb) return Stream.value(_getMockProducts());

    // Watch sản phẩm, khi có thay đổi thì tính lại tồn kho
    return _db.select(_db.products).watch().asyncMap((_) => _fetchWithStock());
  }

  /// Lấy toàn bộ sản phẩm + tồn kho hiện tại bằng raw SQL
  Future<List<ProductEntity>> _fetchWithStock() async {
    final rows = await _db.customSelect(
      '''
      SELECT
        p.id, p.uuid, p.category_id, p.unit_id, p.name,
        p.default_price, p.note, p.is_active, p.created_at,
        pc.name AS category_name,
        u.name AS unit_name, u.symbol AS unit_symbol,
        COALESCE(SUM(i.quantity), 0.0) AS current_stock
      FROM products p
      LEFT JOIN product_categories pc ON pc.id = p.category_id
      LEFT JOIN units u ON u.id = p.unit_id
      LEFT JOIN inventory_entries i ON i.product_id = p.id
      WHERE p.is_active = 1
      GROUP BY p.id
      ORDER BY p.name
      ''',
      readsFrom: {_db.products, _db.productCategories, _db.units, _db.inventoryEntries},
    ).get();

    return rows.map((row) => _mapRow(row)).toList();
  }

  ProductEntity _mapRow(QueryRow row) {
    final d = row.data;
    DateTime createdAt;
    final raw = d['created_at'];
    if (raw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    } else if (raw is String) {
      createdAt = DateTime.parse(raw);
    } else {
      createdAt = DateTime.now();
    }
    final isActiveRaw = d['is_active'];
    final isActive = isActiveRaw == 1 || isActiveRaw == true;

    final catName = d['category_name'] as String?;
    final unitName = d['unit_name'] as String?;
    final unitSymbol = d['unit_symbol'] as String?;

    return ProductEntity(
      id: d['id'] as int,
      uuid: d['uuid'] as String,
      categoryId: d['category_id'] as int,
      category: catName != null
          ? ProductCategoryEntity(id: d['category_id'] as int, uuid: '', name: catName)
          : null,
      unitId: d['unit_id'] as int,
      unit: unitName != null
          ? UnitEntity(id: d['unit_id'] as int, uuid: '', name: unitName, symbol: unitSymbol ?? '')
          : null,
      name: d['name'] as String,
      defaultPrice: d['default_price'] as int?,
      note: d['note'] as String?,
      isActive: isActive,
      createdAt: createdAt,
      currentStock: (d['current_stock'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Future<void> saveProduct(ProductEntity product) async {
    if (kIsWeb) return;

    final companion = ProductsCompanion(
      uuid: Value(product.uuid),
      categoryId: Value(product.categoryId),
      unitId: Value(product.unitId),
      name: Value(product.name),
      defaultPrice: Value(product.defaultPrice),
      note: Value(product.note),
      isActive: Value(product.isActive),
      createdAt: Value(product.createdAt),
      updatedAt: Value(DateTime.now()),
    );

    if (product.id == null) {
      await _dao.insertProduct(companion);
    } else {
      await _dao.updateProduct(companion.copyWith(id: Value(product.id!)));
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    if (kIsWeb) return;
    await (_db.update(_db.products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        isActive: const Value(false),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<List<ProductCategoryEntity>> getCategories() async {
    if (kIsWeb) return _getMockCategories();
    final data = await _dao.getAllCategories();
    return data.map((e) => ProductCategoryEntity(id: e.id, uuid: e.uuid, name: e.name)).toList();
  }

  @override
  Future<List<UnitEntity>> getUnits() async {
    if (kIsWeb) return _getMockUnits();
    final data = await _dao.getAllUnits();
    return data
        .map((e) => UnitEntity(id: e.id, uuid: e.uuid, name: e.name, symbol: e.symbol))
        .toList();
  }

  List<ProductEntity> _getMockProducts() {
    return [
      ProductEntity(
        id: 1,
        uuid: 'p1',
        categoryId: 1,
        unitId: 1,
        name: 'Chứng nước',
        defaultPrice: 25000,
        isActive: true,
        createdAt: DateTime.now(),
        currentStock: 320,
        category: const ProductCategoryEntity(id: 1, uuid: 'c1', name: 'Chứng nước'),
        unit: const UnitEntity(id: 1, uuid: 'u1', name: 'Kilogram', symbol: 'kg'),
      ),
    ];
  }

  List<ProductCategoryEntity> _getMockCategories() {
    return const [
      ProductCategoryEntity(id: 1, uuid: 'c1', name: 'Chứng nước'),
      ProductCategoryEntity(id: 2, uuid: 'c2', name: 'Cá giống'),
    ];
  }

  List<UnitEntity> _getMockUnits() {
    return const [
      UnitEntity(id: 1, uuid: 'u1', name: 'Kilogram', symbol: 'kg'),
      UnitEntity(id: 2, uuid: 'u2', name: 'Bao', symbol: 'bao'),
    ];
  }
}
