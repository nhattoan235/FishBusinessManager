import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_database.dart';

final databaseEncryptionKeyProvider = Provider<String?>((ref) => null);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(
    encryptionKey: ref.watch(databaseEncryptionKeyProvider),
  );
  ref.onDispose(() => db.close());
  return db;
});
