import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Owns the SQLCipher key. The key never enters SQLite tables or application
/// logs and is persisted by the platform keystore/keychain.
class DatabaseEncryptionService {
  static const _storageKey = 'fish_business_database_key_v1';
  static const _secureStorage = FlutterSecureStorage();

  Future<String> getOrCreateKey() async {
    final existing = await _secureStorage.read(key: _storageKey);
    if (existing != null && existing.length == 64) return existing;

    final random = Random.secure();
    final key = List<int>.generate(32, (_) => random.nextInt(256))
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    await _secureStorage.write(key: _storageKey, value: key);
    return key;
  }
}
