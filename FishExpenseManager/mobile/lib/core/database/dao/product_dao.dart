import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/product_categories_table.dart';
import '../tables/products_table.dart';
import '../tables/units_table.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [ProductCategories, Products, Units])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  // Products
  Future<List<ProductData>> getAllProducts() => select(products).get();
  Stream<List<ProductData>> watchAllProducts() => select(products).watch();
  Future<int> insertProduct(ProductsCompanion product) => into(products).insert(product);
  Future<bool> updateProduct(ProductsCompanion product) => update(products).replace(product);
  
  // Categories
  Future<List<ProductCategoryData>> getAllCategories() => select(productCategories).get();
  Future<int> insertCategory(ProductCategoriesCompanion category) => into(productCategories).insert(category);
  
  // Units
  Future<List<UnitData>> getAllUnits() => select(units).get();
  Future<int> insertUnit(UnitsCompanion unit) => into(units).insert(unit);
}
