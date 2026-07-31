class SupplierEntity {
  final int? id;
  final String uuid;
  final String name;
  final String? phone;
  final String? address;
  final String? note;
  final bool isActive;
  final DateTime createdAt;

  const SupplierEntity({
    this.id,
    required this.uuid,
    required this.name,
    this.phone,
    this.address,
    this.note,
    required this.isActive,
    required this.createdAt,
  });
}
