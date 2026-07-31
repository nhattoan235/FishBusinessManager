import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../domain/repositories/sale_repository.dart';
import '../infrastructure/repositories/sale_repository_impl.dart';
import 'use_cases/create_sale_use_case.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SaleRepositoryImpl(db);
});

final createSaleUseCaseProvider = Provider<CreateSaleUseCase>((ref) {
  return CreateSaleUseCase(ref.watch(saleRepositoryProvider));
});
