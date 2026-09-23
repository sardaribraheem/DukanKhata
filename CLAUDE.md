# DukanKhata Project Guidelines

## Overview
DukanKhata is a bilingual (Urdu/English) Flutter application built for small shop owners (specifically tailored with tactile claymorphism UI, large tap targets, and voice/manual entry workflows for auto-repair and spare parts shops).

## Tech Stack
- **Framework**: Flutter (Dart 3.x)
- **Backend & Database**: Supabase (PostgreSQL, Auth, Storage, RLS)
- **State Management**: Flutter Riverpod (`flutter_riverpod`)
- **Routing**: `go_router` with reactive auth redirection
- **UI Design System**: Minimalist Claymorphism (warm stone palette, soft dual shadows, 64px tall big tactile buttons)

## Project Structure
```
lib/
├── main.dart                    # App bootstrap (initializes Supabase & ProviderScope)
├── core/
│   ├── config/
│   │   ├── env.dart             # Compile-time environment constants
│   │   └── supabase.dart        # Supabase client & auth state providers
│   ├── router/
│   │   └── app_router.dart      # GoRouter configuration & auth guard
│   ├── theme/
│   │   ├── colors.dart          # Claymorphic color palette
│   │   ├── typography.dart      # High-contrast font styles
│   │   └── theme.dart           # ThemeData configuration
│   └── utils/                   # Formatters & helper utilities
├── features/
│   ├── auth/                    # Authentication feature (repository, controller, login screen)
│   ├── home/                    # Dashboard / Today's summary feature
│   ├── inventory/               # Product stock management (upcoming)
│   ├── sales/                   # Manual & voice sales entry (upcoming)
│   └── voice/                   # Voice-to-text processing (upcoming)
└── shared/
    ├── models/                  # Data models
    └── widgets/                 # Reusable UI components (ClayContainer, BigButton)
supabase/
└── migrations/                  # PostgreSQL schema, RLS policies & storage buckets
```

## Common Commands

### Running the App
```bash
# Run web with environment defines
flutter run -d chrome --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_PUBLISHABLE_KEY=your_key

# Build web release
flutter build web --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_PUBLISHABLE_KEY=your_key
```

### Quality Assurance
```bash
# Analyze code for warnings/errors
flutter analyze

# Run unit and widget tests
flutter test

# Format code
dart format .
```

## Database & Backend (Supabase)
- **Tables**: `products`, `sales`, `stock_purchases`, `inventory_adjustments`
- **Security**: Row Level Security (RLS) enabled on all tables enforcing `auth.uid() = user_id`.
- **Storage**: `product-photos` bucket configured with owner-only access.

## Coding Standards
- Keep files under 300 lines.
- Use `const` constructors wherever possible.
- Use meaningful variable and function names.
- Follow Effective Dart guidelines.
- Handle errors gracefully with user-friendly feedback in both Urdu and English.
