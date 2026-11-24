import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/glow_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize storage
  await LocalStorageService.init();

  // Initialize Firebase (safely falls back if config is pending)
  await FirebaseService.initializeFirebase();

  runApp(const ProviderScope(child: GlowApp()));
}

class GlowApp extends ConsumerWidget {
  const GlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Glow - AI Skin Health',
      debugShowCheckedModeBanner: false,
      theme: GlowTheme.buildTheme(themeMode),
      routerConfig: appRouter,
    );
  }
}
