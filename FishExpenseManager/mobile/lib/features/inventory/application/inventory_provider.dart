import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../domain/repositories/inventory_repository.dart';
import '../infrastructure/repositories/inventory_repository_impl.dart';
import '../domain/entities/inventory_entity.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryRepositoryImpl(db);
});

final inventorySummaryProvider = StreamProvider<List<InventorySummaryEntity>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchInventorySummary();
});

final inventoryHistoryProvider = FutureProvider<List<InventoryEntryEntity>>((ref) {
  return ref.watch(inventoryRepositoryProvider).getInventoryHistory();
});
