import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getAllCustomers();
  Stream<List<CustomerEntity>> watchAllCustomers();
  Future<void> saveCustomer(CustomerEntity customer);
  Future<void> deleteCustomer(int id);
}
