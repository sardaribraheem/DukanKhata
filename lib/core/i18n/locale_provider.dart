import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to hold active locale: only ur or en at a time.
final localeProvider = StateProvider<Locale>((ref) => const Locale('ur', 'PK'));

/// Toggle between Urdu (ur) and English (en).
void toggleLocale(WidgetRef ref) {
  final current = ref.read(localeProvider);
  ref.read(localeProvider.notifier).state =
      current.languageCode == 'ur' ? const Locale('en', 'US') : const Locale('ur', 'PK');
}
