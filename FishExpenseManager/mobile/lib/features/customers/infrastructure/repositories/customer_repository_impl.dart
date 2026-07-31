import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/dao/customer_dao.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerDao _dao;

  CustomerRepositoryImpl(this._dao);

  @override
  Future<List<CustomerEntity>> getAllCustomers() async {
    if (kIsWeb) {
      return [
        CustomerEntity(id: 1, uuid: '1', name: 'Nguyễn Văn A', phone: '0901234567', isActive: true, createdAt: DateTime.now()),
        CustomerEntity(id: 2, uuid: '2', name: 'Trần Thị B', phone: '0912345678', isActive: true, createdAt: DateTime.now()),
      ];
    }
    final data = await _dao.getAllCustomers();
    return data.map(_map).toList();
  }

  @override
  Stream<List<CustomerEntity>> watchAllCustomers() {
    if (kIsWeb) {
      return Stream.value([
        CustomerEntity(id: 1, uuid: '1', name: 'Nguyễn Văn A', phone: '0901234567', isActive: true, createdAt: DateTime.now()),
        CustomerEntity(id: 2, uuid: '2', name: 'Trần Thị B', phone: '0912345678', isActive: true, createdAt: DateTime.now()),
      ]);
    }
    return _dao.watchAllCustomers().map((list) => list.map(_map).toList());
  }

  @override
  Future<void> saveCustomer(CustomerEntity customer) async {
    if (kIsWeb) return;
    
    final companion = CustomersCompanion(
      uuid: Value(customer.uuid),
      name: Value(customer.name),
      phone: Value(customer.phone),
      address: Value(customer.address),
      note: Value(customer.note),
      isActive: Value(customer.isActive),
      createdAt: Value(customer.createdAt),
    );
    if (customer.id == null) {
      await _dao.insertCustomer(companion.copyWith(updatedAt: Value(DateTime.now())));
    } else {
      await _dao.updateCustomer(companion.copyWith(
        id: Value(customer.id!),
        updatedAt: Value(DateTime.now())
      ));
    }
  }

  @override
  Future<int> addCustomer(CustomerEntity customer) async {
    if (kIsWeb) return 999; // Mock ID for web
    final companion = CustomersCompanion(
      uuid: Value(customer.uuid),
      name: Value(customer.name),
      phone: Value(customer.phone),
      address: Value(customer.address),
      note: Value(customer.note),
      isActive: Value(customer.isActive),
      createdAt: Value(customer.createdAt),
      updatedAt: Value(DateTime.now()),
    );
    return await _dao.insertCustomer(companion);
  }

  @override
  Future<void> deleteCustomer(int id) async {
    if (kIsWeb) return;
    await _dao.softDeleteCustomer(id);
  }

  CustomerEntity _map(CustomerData data) {
    return CustomerEntity(
      id: data.id,
      uuid: data.uuid,
      name: data.name,
      phone: data.phone,
      address: data.address,
      note: data.note,
      isActive: data.isActive,
      createdAt: data.createdAt,
    );
  }
}
