/// Compile-time environment configuration.
///
/// Values can be injected at build time with `--dart-define=...`.
/// Sensible development defaults are provided for convenience so `flutter run -d chrome`
/// works out of the box without requiring manual flag entry every time.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ondgpbyqxynitwfyfpdz.supabase.co',
  );

  /// Publishable key (frontend-safe). Never commit the service_role key.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_w71Zs-gpvsyPk-OuZ1bPpQ_8Eu0ztDJ',
  );
}
