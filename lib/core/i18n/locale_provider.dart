import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to hold active locale: only ur or en at a time.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ur', 'PK')) {
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString('language_code');
    if (languageCode == 'en') state = const Locale('en', 'US');
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'ur'
        ? const Locale('en', 'US')
        : const Locale('ur', 'PK');
    state = next;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('language_code', next.languageCode);
  }
}

/// Toggle between Urdu (ur) and English (en).
void toggleLocale(WidgetRef ref) {
  ref.read(localeProvider.notifier).toggle();
}
