import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/theme/app_theme.dart';
import 'router.dart';

/// The root widget of the NeighborShare application.
/// 
/// This widget configures the app with:
/// - Material Design 3 theming (light and dark modes)
/// - GoRouter for navigation with auth-based redirects
/// - Riverpod for state management
class NeighborShareApp extends ConsumerWidget {
  const NeighborShareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NeighborShare',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // Follows system theme preference
      
      // Router configuration
      routerConfig: router,
    );
  }
}
