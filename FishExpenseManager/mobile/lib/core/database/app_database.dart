import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/customers_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/product_categories_table.dart';
import 'tables/units_table.dart';
import 'tables/products_table.dart';
import 'tables/sale_documents_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/inventory_entries_table.dart';
import 'tables/transactions_table.dart';
import 'tables/customer_balances_table.dart';
import 'tables/debt_transactions_table.dart';
import 'tables/app_settings_table.dart';
import 'tables/backup_logs_table.dart';
import 'tables/app_logs_table.dart';
import 'tables/database_info_table.dart';

import 'dao/customer_dao.dart';
import 'dao/supplier_dao.dart';
import 'dao/product_dao.dart';
import 'dao/sale_dao.dart';
import 'dao/transaction_dao.dart';
import 'dao/inventory_dao.dart';
import 'dao/debt_dao.dart';
import 'dao/settings_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Customers,
    Suppliers,
    ProductCategories,
    Units,
    Products,
    SaleDocuments,
    SaleItems,
    InventoryEntries,
    Transactions,
    CustomerBalances,
    DebtTransactions,
    AppSettings,
    BackupLogs,
    AppLogs,
    DatabaseInfo,
  ],
  daos: [
    CustomerDao,
    SupplierDao,
    ProductDao,
    SaleDao,
    TransactionDao,
    InventoryDao,
    DebtDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(e ?? driftDatabase(
          name: 'fish_business_manager_db',
        ));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedData();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migration paths for future database schema updates
        },
      );

  Future<void> _seedData() async {
    const uuid = Uuid();
    final now = DateTime.now();

    // 1. Seed Units
    await into(units).insert(UnitsCompanion.insert(
      uuid: uuid.v4(),
      name: 'Kilogram',
      symbol: 'kg',
      createdAt: Value(now),
    ));
    await into(units).insert(UnitsCompanion.insert(
      uuid: uuid.v4(),
      name: 'Bao',
      symbol: 'bao',
      createdAt: Value(now),
    ));
    await into(units).insert(UnitsCompanion.insert(
      uuid: uuid.v4(),
      name: 'Con',
      symbol: 'con',
      createdAt: Value(now),
    ));
    await into(units).insert(UnitsCompanion.insert(
      uuid: uuid.v4(),
      name: 'Thùng',
      symbol: 'thùng',
      createdAt: Value(now),
    ));

    // 2. Seed Product Categories
    final categoryId = await into(productCategories).insert(
      ProductCategoriesCompanion.insert(
        uuid: uuid.v4(),
        name: 'Chứng nước',
        description: const Value('Chứng nước tự nuôi và thu mua'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await into(productCategories).insert(
      ProductCategoriesCompanion.insert(
        uuid: uuid.v4(),
        name: 'Cá giống',
        description: const Value('Các loại cá giống'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // 3. Seed Default Product: "Chứng nước" (id = 1, unit_id = 1)
    await into(products).insert(
      ProductsCompanion.insert(
        uuid: uuid.v4(),
        categoryId: categoryId,
        unitId: 1, // kg
        name: 'Chứng nước',
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // 4. Seed App Settings
    await into(appSettings).insert(
      AppSettingsCompanion.insert(
        id: const Value(1),
        fontScale: const Value(1.0),
        theme: const Value('light'),
        autoBackup: const Value(true),
        backupInterval: const Value(24),
        keepBackupDays: const Value(30),
        useGoogleDrive: const Value(false),
        updatedAt: Value(now),
      ),
    );

    // 5. Seed Database Info
    await into(databaseInfo).insert(
      DatabaseInfoCompanion.insert(
        id: const Value(1),
        schemaVersion: 1,
        databaseVersion: 1,
      ),
    );
  }
}
