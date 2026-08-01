import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fish_business_manager/core/database/app_database.dart';
import 'package:fish_business_manager/core/database/providers/database_provider.dart';

/// Helper to create a test ProviderContainer with an in-memory database
ProviderContainer createTestProviderContainer() {
  // Create an in-memory database using NativeDatabase
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
    ],
  );

  return container;
}
