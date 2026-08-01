import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/providers/database_provider.dart';
import 'core/security/database_encryption_service.dart';
import 'core/services/background_backup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final encryptionKey =
      kIsWeb ? null : await DatabaseEncryptionService().getOrCreateKey();
  await initializeBackgroundBackup();
  runApp(
    ProviderScope(
      overrides: [
        databaseEncryptionKeyProvider.overrideWithValue(encryptionKey)
      ],
      child: const FishBusinessApp(),
    ),
  );
}
