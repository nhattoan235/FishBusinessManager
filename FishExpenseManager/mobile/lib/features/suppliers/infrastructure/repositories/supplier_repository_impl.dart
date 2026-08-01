import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/dao/supplier_dao.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierDao _dao;

  SupplierRepositoryImpl(this._dao);

  @override
  Future<List<SupplierEntity>> getAllSuppliers() async {
    final data = await _dao.getAllSuppliers();
    return data.map(_map).toList();
  }

  @override
  Stream<List<SupplierEntity>> watchAllSuppliers() {
    return _dao.watchAllSuppliers().map((list) => list.map(_map).toList());
  }

  @override
  Future<void> saveSupplier(SupplierEntity supplier) async {
    final companion = SuppliersCompanion(
      uuid: Value(supplier.uuid),
      name: Value(supplier.name),
      phone: Value(supplier.phone),
      address: Value(supplier.address),
      note: Value(supplier.note),
      isActive: Value(supplier.isActive),
      createdAt: Value(supplier.createdAt),
    );
    if (supplier.id == null) {
      await _dao
          .insertSupplier(companion.copyWith(updatedAt: Value(DateTime.now())));
    } else {
      await _dao.updateSupplier(companion.copyWith(
          id: Value(supplier.id!), updatedAt: Value(DateTime.now())));
    }
  }

  @override
  Future<void> deleteSupplier(int id) async {
    await _dao.softDeleteSupplier(id);
  }

  SupplierEntity _map(SupplierData data) {
    return SupplierEntity(
      id: data.id,
      uuid: data.uuid,
      name: data.name,
      phone: data.phone,
      address: data.address,
      note: data.note,
      isActive: data.isActive,
      createdAt: data.createdAt,
    );
  }
}
