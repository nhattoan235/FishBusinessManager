import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers/database_provider.dart';
import '../domain/repositories/customer_repository.dart';
import '../infrastructure/repositories/customer_repository_impl.dart';
import '../domain/entities/customer_entity.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomerRepositoryImpl(db.customerDao);
});

final customersProvider = StreamProvider<List<CustomerEntity>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.watchAllCustomers();
});
