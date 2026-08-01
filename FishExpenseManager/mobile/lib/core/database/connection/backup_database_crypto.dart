import 'backup_database_crypto_stub.dart'
    if (dart.library.io) 'backup_database_crypto_native.dart' as implementation;

Future<void> encryptPlaintextDatabase({
  required String sourcePath,
  required String destinationPath,
  required String encryptionKey,
}) =>
    implementation.encryptPlaintextDatabase(
      sourcePath: sourcePath,
      destinationPath: destinationPath,
      encryptionKey: encryptionKey,
    );
