import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../app_database.dart';

/// AppDatabase single instance provider
final databaseProvider = Provider<AppDatabase>((ref) {
  if (kIsWeb) {
    // Return dummy database to bypass Drift web setup requirements
    // since we use mock data in repositories for Web development.
    return AppDatabase(_DummyExecutor());
  }
  
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

class _DummyExecutor extends QueryExecutor {
  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async => true;
  @override
  Future<void> runBatched(BatchedStatements statements) async {}
  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {}
  @override
  Future<int> runDelete(String statement, List<Object?> args) async => 0;
  @override
  Future<int> runInsert(String statement, List<Object?> args) async => 0;
  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, [List<Object?>? args]) async => [];
  @override
  Future<int> runUpdate(String statement, List<Object?> args) async => 0;
  @override
  TransactionExecutor beginTransaction() => throw UnimplementedError();
  @override
  QueryExecutor beginExclusive() => throw UnimplementedError();
  @override
  SqlDialect get dialect => SqlDialect.sqlite;
  bool get isOpen => true;
  @override
  Future<void> close() async {}
}
