import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/inventory_entries_table.dart';

part 'inventory_dao.g.dart';

@DriftAccessor(tables: [InventoryEntries])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.db);

  Future<List<InventoryEntryData>> getAllEntries() => select(inventoryEntries).get();
  
  Stream<List<InventoryEntryData>> watchAllEntries() => select(inventoryEntries).watch();
  
  Future<int> insertEntry(InventoryEntriesCompanion entry) => into(inventoryEntries).insert(entry);
}
