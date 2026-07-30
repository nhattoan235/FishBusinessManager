import 'package:drift/drift.dart';
import 'customers_table.dart';

@DataClassName('CustomerBalanceData')
class CustomerBalances extends Table {
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get currentDebt => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {customerId};
}
