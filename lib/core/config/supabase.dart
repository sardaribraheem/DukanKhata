import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Riverpod provider for the initialized Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream of auth changes for reactive routing / UI updates.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Current authenticated user (or null).
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

/// Initializes Supabase. Must be awaited in `main()` before `runApp`.
///
/// Throws if the URL or publishable key are empty — that means the app was
/// built without `--dart-define`. See `CLAUDE.md`.
Future<void> initializeSupabase() async {
  if (Env.supabaseUrl.isEmpty || Env.supabasePublishableKey.isEmpty) {
    throw StateError(
      'Supabase credentials missing. Build with '
      '--dart-define=SUPABASE_URL=... '
      '--dart-define=SUPABASE_PUBLISHABLE_KEY=...',
    );
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
}

/// Convenience accessor for the shared client.
SupabaseClient get supabase => Supabase.instance.client;