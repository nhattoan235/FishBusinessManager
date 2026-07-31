import '../entities/supplier_entity.dart';

abstract class SupplierRepository {
  Future<List<SupplierEntity>> getAllSuppliers();
  Stream<List<SupplierEntity>> watchAllSuppliers();
  Future<void> saveSupplier(SupplierEntity supplier);
  Future<void> deleteSupplier(int id);
}
