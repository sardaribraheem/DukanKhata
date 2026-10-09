import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase.dart';
import 'core/i18n/app_strings.dart';
import 'core/i18n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_database.dart';
import 'core/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using --dart-define injected credentials (with dev defaults)
  await initializeSupabase();
  await LocalDatabase.instance.initialize();
  await LocalDatabase.instance.log('LOCAL DATABASE INITIALIZED', {});

  runApp(const ProviderScope(child: DukanKhataApp()));
}

class DukanKhataApp extends ConsumerWidget {
  const DukanKhataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isUrdu = ref.watch(localeProvider).languageCode == 'ur';

    return MaterialApp.router(
      title: appText(isUrdu, 'دکان کھاتہ', 'Dukan Khata'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
