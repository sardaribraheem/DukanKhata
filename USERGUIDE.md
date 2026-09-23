# DukanKhata User Guide & Technical Documentation
(دکان کھاتہ یوزر گائیڈ اور تکنیکی دستاویزات)

---

## 1. Overview & Purpose
**DukanKhata** is a bilingual (Urdu & English) Flutter mobile/web application designed specifically for small shop owners, auto-repair shops, and spare parts dealers. It features a tactile minimalist claymorphic UI with oversized touch targets and streamlined workflows for manual and voice-activated sales entry.

---

## 2. Tech Stack & Architecture
- **Framework**: Flutter (Dart 3.x)
- **Backend & Database**: Supabase (PostgreSQL, Row Level Security, Storage)
- **State Management**: Flutter Riverpod (`flutter_riverpod` with `AsyncNotifierProvider`)
- **Routing**: `go_router` with reactive auth redirection
- **Design System**: Claymorphism (Warm stone palette `#F4F5F7`, soft shadows, 64px tall tactile buttons, high contrast typography)

---

## 3. Implemented Phases & Features

### Phase 1: Foundation & Authentication
- Supabase initialization and secure environment configuration.
- Email/Password authentication with reactive routing guard.
- Login and Signup screens with bilingual helper text and error handling.

### Phase 2: Product Inventory Management (`/inventory`)
- **Categories**: Oils & Fluids, Spare Parts, Tires & Tubes, Batteries, Small Hardware, Others.
- **Search & Filtering**: Real-time search bar, category filter chips, and favorite toggle filter.
- **Add & Restock**: Modal dialogs to add new products (with mock photo/storage upload) and restock items, automatically logging entries into `stock_purchases`.
- **Inventory Adjustments**: Tracks adjustments for damaged/lost stock into `inventory_adjustments`.

### Phase 3: Manual Sales & Khata (`/khata` & Dashboard Summary)
- **Manual Sale Entry**: Product dropdown showing live stock counts, quantity selector (`+` / `-`), and editable negotiated price field.
- **Revenue & Profit Tracking**: Automatically computes revenue (`qty * sale_price`), cost (`qty * cost_price`), and profit (`revenue - cost`).
- **Stock Decrement**: Instantly decrements inventory upon sale confirmation.
- **Today's Khata Screen**: Displays daily totals (Revenue, Profit, Items Sold) and itemized list of today's sales.

### Phase 4: Voice AI Sales Entry (`VoiceSaleDialog`)
- **Speech-to-Text Simulation**: Allows shop owners to speak naturally in Urdu (e.g., *"تین انجن آئل 900 روپے کے بیچے"*).
- **AI Intent Extraction**: Automatically parses product match, quantity, and agreed price.
- **One-Tap Confirmation**: Reviews extracted data and commits the sale instantly.

### Phase 5 & 6: UX Polish, Testing & Deployment
- **Accessibility & Contrast**: Oversized buttons (64px height) and high-contrast text for shop owners.
- **Quality Assurance**: Passing all Flutter analyzer checks and unit/widget tests.

---

## 4. Running the App

```bash
# Get dependencies
flutter pub get

# Run in Chrome with Supabase environment defines
flutter run -d chrome --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_PUBLISHABLE_KEY=your_key
```

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
