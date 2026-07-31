import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../infrastructure/repositories/debt_repository_impl.dart';
import '../domain/entities/debt_item_entity.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DebtRepositoryImpl(db);
});

final debtListProvider = StreamProvider<List<DebtItemEntity>>((ref) {
  return ref.watch(debtRepositoryProvider).watchDebtList();
});
