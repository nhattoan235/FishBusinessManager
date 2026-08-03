import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/customers_table.dart';
import '../tables/customer_balances_table.dart';

part 'customer_dao.g.dart';

@DriftAccessor(tables: [Customers, CustomerBalances])
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Future<List<CustomerData>> getAllCustomers() => select(customers).get();

  Stream<List<CustomerData>> watchAllCustomers() => (select(customers)
        ..where((row) => row.isActive.equals(true))
        ..orderBy([(row) => OrderingTerm.asc(row.name)]))
      .watch();

  Stream<CustomerData?> watchCustomerById(int id) =>
      (select(customers)..where((row) => row.id.equals(id)))
          .watchSingleOrNull();

  Future<int> insertCustomer(CustomersCompanion customer) =>
      into(customers).insert(customer);

  Future<bool> updateCustomer(CustomersCompanion customer) =>
      update(customers).replace(customer);

  Future<int> softDeleteCustomer(int id) {
    return (update(customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(
        isActive: const Value(false),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }
}
