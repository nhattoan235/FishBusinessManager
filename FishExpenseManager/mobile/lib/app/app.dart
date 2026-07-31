import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_constants.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/settings/application/settings_provider.dart';

class FishBusinessApp extends ConsumerWidget {
  const FishBusinessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
