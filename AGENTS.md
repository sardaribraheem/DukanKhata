# DukanKhata contributor guide

## Project
DukanKhata is an Urdu/English Flutter app for shop inventory and daily sales
records. It uses Riverpod for state, go_router for navigation, sqflite for local
business data, and Supabase for backend/auth infrastructure. Check the current
implementation before relying on older plans in `todo.md` or `CLAUDE.md`.

## Layout
- `lib/main.dart`: Supabase and local database initialization, ProviderScope,
  and application entry point.
- `lib/core/`: configuration, localization, logging, SQLite storage, routing,
  and the shared theme.
- `lib/features/`: auth, home, inventory, sales, voice entry, and settings;
  repositories, providers, and presentation code live inside each feature.
- `lib/shared/`: product/sale models and reusable widgets.
- `supabase/migrations/`: versioned SQL schema and data changes.
- `test/`: Flutter tests; the existing smoke test only checks the app class.
- Platform folders contain native integration and generated plugin registration.

## Commands
Use a Flutter SDK compatible with the Dart constraint in `pubspec.yaml`.

```sh
flutter pub get
flutter analyze
flutter test
dart format lib test
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_PUBLISHABLE_KEY=your_key
```

Run analysis and relevant tests after behavior changes. Format only touched Dart
files when unrelated edits are present. Do not describe the existing smoke test
as validation of inventory, sales, or database behavior.

## Implementation conventions
- Keep business and persistence logic in repositories/providers, with UI code in
  presentation files. Reuse existing theme tokens and shared widgets.
- Preserve Urdu/English strings, language switching, large tap targets, and
  readable layouts. Follow the localization helpers in `lib/core/i18n/`.
- The current router opens the local shop workspace without requiring login.
  Do not assume Supabase authentication gates local features.
- Preserve transaction consistency between sales, stock, and adjustments, and
  historical sale snapshots when products change or are deleted.
- For local schema changes, increment the SQLite database version and implement
  an upgrade path; `onCreate` changes alone do not update existing databases.
- Add new Supabase migrations instead of rewriting migrations already applied.
  Preserve owner-scoped RLS and storage policies.
- Prefer const constructors, clear names, and user-friendly localized errors.
- Keep service-role credentials, tokens, local databases, and build artifacts
  out of Git. Supabase configuration accepts compile-time dart defines.
- Commit `pubspec.lock` and required generated platform registrants when
  dependencies change. Regenerate launcher icons from the asset configured in
  `pubspec.yaml` rather than editing each image manually.

## Platform limits
The local store currently uses sqflite without a web adapter. Verify platform
support before promising browser functionality or using Chrome as a smoke test.
Do not deploy Supabase migrations as part of routine local edits unless requested.
