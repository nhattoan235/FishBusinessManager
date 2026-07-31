import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class RecordTransactionUseCase {
  final TransactionRepository _repository;

  RecordTransactionUseCase(this._repository);

  Future<void> execute({
    required double amount,
    required bool isIncome,
    required String type,
    required String description,
    required DateTime date,
  }) async {
    if (amount <= 0) {
      throw Exception('Số tiền phải lớn hơn 0');
    }
    if (type.isEmpty) {
      throw Exception('Vui lòng chọn loại giao dịch');
    }

    final transaction = TransactionEntity(
      uuid: const Uuid().v4(),
      amount: amount,
      isIncome: isIncome,
      type: type,
      description: description,
      date: date,
      createdAt: DateTime.now(),
    );

    await _repository.recordTransaction(transaction);
  }
}
