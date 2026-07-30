import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_constants.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FishBusinessApp extends ConsumerWidget {
  const FishBusinessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
