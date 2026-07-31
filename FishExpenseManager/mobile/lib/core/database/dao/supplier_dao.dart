import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/suppliers_table.dart';

part 'supplier_dao.g.dart';

@DriftAccessor(tables: [Suppliers])
class SupplierDao extends DatabaseAccessor<AppDatabase> with _$SupplierDaoMixin {
  SupplierDao(super.db);

  Future<List<SupplierData>> getAllSuppliers() => select(suppliers).get();
  
  Stream<List<SupplierData>> watchAllSuppliers() => select(suppliers).watch();
  
  Future<int> insertSupplier(SuppliersCompanion supplier) => into(suppliers).insert(supplier);
  
  Future<bool> updateSupplier(SuppliersCompanion supplier) => update(suppliers).replace(supplier);
  
  Future<int> softDeleteSupplier(int id) {
    return (update(suppliers)..where((t) => t.id.equals(id))).write(
      SuppliersCompanion(
        deletedAt: Value(DateTime.now()),
      ),
    );
  }
}
