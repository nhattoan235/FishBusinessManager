import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_constants.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/settings/application/settings_provider.dart';

class FishBusinessApp extends ConsumerStatefulWidget {
  const FishBusinessApp({super.key});

  @override
  ConsumerState<FishBusinessApp> createState() => _FishBusinessAppState();
}

class _FishBusinessAppState extends ConsumerState<FishBusinessApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(autoBackupCoordinatorProvider).backupIfDirty(reason: 'app_exit');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(automaticBackupEnabledProvider)) {
      ref.watch(autoBackupCoordinatorProvider);
    }
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(appSettingsProvider);

    // Default settings
    double fontScale = 1.0;
    bool useBoldFont = false;

    settingsAsync.whenData((settings) {
      fontScale = settings.fontScale;
      useBoldFont = settings.useBoldFont;
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(
        fontScale: fontScale,
        useBoldFont: useBoldFont,
      ),
      routerConfig: router,
    );
  }
}
