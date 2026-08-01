import 'background_backup_stub.dart'
    if (dart.library.io) 'background_backup_native.dart' as implementation;

Future<void> initializeBackgroundBackup() =>
    implementation.initializeBackgroundBackup();

Future<void> scheduleBackgroundBackup(Duration frequency) =>
    implementation.scheduleBackgroundBackup(frequency);

Future<void> cancelBackgroundBackup() =>
    implementation.cancelBackgroundBackup();
