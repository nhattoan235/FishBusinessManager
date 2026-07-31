class CustomerEntity {
  final int? id;
  final String uuid;
  final String name;
  final String? phone;
  final String? address;
  final String? note;
  final bool isActive;
  final DateTime createdAt;

  const CustomerEntity({
    this.id,
    required this.uuid,
    required this.name,
    this.phone,
    this.address,
    this.note,
    this.isActive = true,
    required this.createdAt,
  });
}
