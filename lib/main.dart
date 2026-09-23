import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using --dart-define injected credentials (with dev defaults)
  await initializeSupabase();

  runApp(
    const ProviderScope(
      child: DukanKhataApp(),
    ),
  );
}

class DukanKhataApp extends ConsumerWidget {
  const DukanKhataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'دکان کھاتہ • Dukan Khata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
