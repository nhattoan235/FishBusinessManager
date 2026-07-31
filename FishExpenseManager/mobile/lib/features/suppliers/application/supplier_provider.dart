import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../domain/repositories/supplier_repository.dart';
import '../infrastructure/repositories/supplier_repository_impl.dart';
import '../domain/entities/supplier_entity.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SupplierRepositoryImpl(db.supplierDao);
});

final supplierListProvider = StreamProvider<List<SupplierEntity>>((ref) {
  final repo = ref.watch(supplierRepositoryProvider);
  return repo.watchAllSuppliers();
});
