import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../domain/repositories/product_repository.dart';
import '../infrastructure/repositories/product_repository_impl.dart';
import '../infrastructure/repositories/product_detail_repository.dart';
import '../domain/entities/product_entity.dart';
import '../domain/entities/product_detail_entity.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductRepositoryImpl(db);
});

final productListProvider = StreamProvider<List<ProductEntity>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchAllProducts();
});

final productCategoriesProvider = FutureProvider<List<ProductCategoryEntity>>((ref) {
  return ref.watch(productRepositoryProvider).getCategories();
});

final productUnitsProvider = FutureProvider<List<UnitEntity>>((ref) {
  return ref.watch(productRepositoryProvider).getUnits();
});

final productDetailRepoProvider = Provider<ProductDetailRepository>((ref) {
  return ProductDetailRepository(ref.watch(databaseProvider));
});

final productDetailProvider =
    FutureProvider.family<ProductDetailData, int>((ref, productId) {
  return ref.watch(productDetailRepoProvider).getProductDetail(productId);
});
