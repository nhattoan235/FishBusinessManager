import '../entities/sale_entity.dart';

abstract class SaleRepository {
  Future<void> createSale(SaleEntity sale);
}
