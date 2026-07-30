abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.code]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

class InsufficientStockFailure extends Failure {
  final double requestedQuantity;
  final double availableQuantity;

  const InsufficientStockFailure({
    required String productName,
    required this.requestedQuantity,
    required this.availableQuantity,
  }) : super('Không đủ tồn kho cho $productName (Cần: $requestedQuantity, Còn: $availableQuantity)');
}

class BackupFailure extends Failure {
  const BackupFailure(super.message, [super.code]);
}

class RestoreFailure extends Failure {
  const RestoreFailure(super.message, [super.code]);
}
