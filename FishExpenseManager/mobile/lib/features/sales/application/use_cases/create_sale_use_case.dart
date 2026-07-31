import 'package:uuid/uuid.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sale_repository.dart';

class CreateSaleUseCase {
  final SaleRepository _repository;

  CreateSaleUseCase(this._repository);

  Future<void> execute({
    required int customerId,
    required double totalAmount,
    required double paidAmount,
    required DateTime saleDate,
    required List<SaleItemEntity> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('Vui lòng chọn ít nhất 1 sản phẩm');
    }
    if (paidAmount < 0 || paidAmount > totalAmount) {
      throw Exception('Số tiền thanh toán không hợp lệ');
    }

    final debtAmount = totalAmount - paidAmount;

    final sale = SaleEntity(
      uuid: const Uuid().v4(),
      customerId: customerId,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      debtAmount: debtAmount,
      saleDate: saleDate,
      createdAt: DateTime.now(),
      items: items,
    );

    await _repository.createSale(sale);
  }
}
