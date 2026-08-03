import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getAllProducts();
  Stream<List<ProductEntity>> watchAllProducts();
  Future<void> saveProduct(
    ProductEntity product, {
    double initialStock = 0,
  });
  Future<void> deleteProduct(int id);

  Future<List<ProductCategoryEntity>> getCategories();
  Future<List<UnitEntity>> getUnits();
}
