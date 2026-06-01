# AGENTS.md — Wash Club Mobile App

## Project Overview

Flutter mobile app for car wash booking in Uzbekistan. Users can browse branches, book car wash services, track orders, and manage saved cars. Backend is **Supabase** (PostgreSQL). App operates with an anonymous key — no real user auth. Local session via `SharedPreferences`.

Targets: Android, iOS, macOS, Linux, Windows.

---

## Essential Commands

```bash
# Code generation (i18n + assets — MUST run after changing .i18n.json files or assets)
flutter pub run build_runner build --delete-conflicting-outputs

# i18n-specific generation (alternative)
dart run slang

# Build
flutter build apk --release
flutter build apk --split-per-abi
flutter build appbundle --release
flutter build ios --release

# Test
flutter test

# Lint / analyze
flutter analyze
```

---

## Architecture & Data Flow

```
main.dart           →  Supabase init, SharedPreferences, locale setup
  └─ app.dart        →  ThemeProvider + TranslationProvider wrapping MaterialApp.router
       └─ router.dart →  GoRouter with StatefulShellRoute (bottom nav)
            ├─ SplashScreen    → redirect to language or login or home
            ├─ LanguageScreen  → pick locale
            ├─ LoginScreen     → name + phone → ClientSession.saveProfile()
            ├─ MainScreen      → bottom nav shell (Home, Booking, Orders, Profile)
            ├─ AddCarScreen    → saves car to ClientSession
            ├─ NotificationScreen
            ├─ SettingsScreen
            └─ ProfileScreen
```

### Navigation

- GoRouter with `StatefulShellRoute.indexedStack` for bottom tab navigation
- Route paths defined in `UserRoutePath` class in `lib/config/router/router.dart`
- Top-level routes: splash, language, login, addCar, notifications, settings
- Shell branches: home, booking, orders, profile
- Navigation within screens uses `context.push()` / `context.go()` / `context.pop()`
- Extra data passed as `state.extra` (e.g., `AddCarScreen` receives `VoidCallback? onCarAdded`)

### Data Layer (top-down)

```
UI (Screens)
  → Repositories (API-first, no cache)
      → SupabaseService (raw Supabase queries)
```

**All repositories live in `lib/shared/services/`** — `BranchesRepository`, `OrdersRepository`. The `lib/data/repositories/` directory still has `BranchesRepository` (duplicate), but OrdersRepository duplication has been resolved. When editing, always update the `lib/shared/services/` versions.

**API-first approach**: Repositories do NOT cache data in memory. Every call to `loadOrders()` or `getBranches()` hits the Supabase API directly. Realtime subscriptions (Supabase RealtimeChannel) push updates to streams, which UI listens to for live updates.

The `lib/data/` directory also has empty `models/` and `datasources/` directories suggesting a planned clean architecture that was never fully implemented.

### Models

All models live in **`lib/shared/services/supabase_service.dart`** at the bottom of the file:
- `BranchModel`, `ServiceModel`, `CustomerModel`, `OrderModel`
- `SavedCar` lives in `lib/shared/services/client_session.dart`

This is not conventional — models should ideally be in `lib/data/models/` or separate files. But this is the current state; don't move them unless asked.

### Session & Auth

The app has **no real authentication**. Users provide name + phone on the login screen, which is stored in `SharedPreferences` via `ClientSession` (singleton). This is used to:
- Identify the user for orders (car number is the primary identifier)
- Pre-fill login form on revisit
- Manage saved cars

Google Sign-In is wired in `LoginScreen` but primarily used to populate the name field — the Supabase auth is token-only, not session-based.

### Supabase Integration

- Initialized in `main.dart` with `Supabase.initialize()` using anon key
- `SupabaseService` (singleton) handles all DB queries
- Realtime subscriptions for active orders via `RealtimeChannel`
- Tables used: `branches`, `services`, `service_prices`, `customers`, `orders`
- All client-created orders have `source = 'by_client_app'` for RLS policy matching

---

## Theme System

Custom `ApparenceKit` theme via `ThemeExtension`:

| Component | File |
|-----------|------|
| `ApparenceKitColors` (light/dark) | `lib/core/theme/colors.dart` |
| `ApparenceKitTextTheme` | `lib/core/theme/texts.dart` |
| `AppTheme` (ChangeNotifier) | `lib/core/theme/providers/theme_provider.dart` |
| `ThemeProvider` (InheritedNotifier) | `lib/core/theme/providers/theme_provider.dart` |

**Accessing theme in widgets:**

```dart
// Colors
final colors = Theme.of(context).extension<ApparenceKitColors>()!;
// or via extension (preferred):
final colors = context.colors;  // from theme_extension.dart

// Theme mode toggle
ThemeProvider.of(context).toggle();
```

The theme is an `InheritedNotifier<AppTheme>`, accessed via `ThemeProvider.of(context)`. Colors and text themes are attached to `ThemeData.extensions`.

---

## Internationalization (i18n)

Uses `slang` package (NOT Flutter's built-in `flutter_localizations`).

- Base locale: `uz` (Uzbek)
- Languages: `uz`, `ru`, `en`
- Config: `slang.yaml` in project root
- Source files: `lib/core/i18n/{uz,ru,en}.i18n.json`
- Generated output: `lib/core/i18n/translations.g.dart` and per-locale files
- Generated class name: `Translations`
- Access key: `t` (via `TranslateVar`)

**Usage in widgets:**

```dart
// Import the extension
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

// Use in build context
final t = context.t;
Text(t.home.goodMorning);
```

**After editing .i18n.json files**, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
# or
dart run slang
```

---

## Naming Conventions & Patterns

- **Comments in Uzbek** — code comments throughout the project are written in Uzbek, including Uzbek + Russian mixed (e.g., "Zabronировать")
- **Singleton services/repos**: `ClassName._(); static final instance = ClassName._();`
- **StatefulWidgets** for screens (no BLoC/Cubit/Provider state management in active use, despite `bloc` being in pubspec)
- **`_` private methods** for UI decomposition (e.g., `_buildHeader`, `_buildBranches`)
- **`mounted` checks** before `setState` in async callbacks
- **Controllers** are disposed in `dispose()` method
- **Animations** using `AnimationController` with `SingleTickerProviderStateMixin`

---

## Key Files Reference

| Purpose | Path |
|---------|------|
| App entry | `lib/main.dart` |
| App widget + theme setup | `lib/app.dart` |
| Router + route paths | `lib/config/router/router.dart` |
| Supabase queries | `lib/shared/services/supabase_service.dart` *(also contains all models)* |
| Local session | `lib/shared/services/client_session.dart` |
| Constants | `lib/shared/constants/app_constants.dart` |
| API keys/URLs | `lib/shared/api_constants.dart` |
| Theme colors | `lib/core/theme/colors.dart` |
| i18n extension | `lib/core/i18n/extensions/i18n_extension.dart` |
| Theme extension | `lib/core/theme/extensions/theme_extension.dart` |
| Reusable text field | `lib/core/widgets/app_text_field.dart` |

---

## Gotchas

1. **Repository duplication** — `lib/shared/services/` and `lib/data/repositories/` had identical `OrdersRepository`. The duplicate in `lib/data/repositories/` has been deleted. All screens now import from `lib/shared/services/orders_repository.dart`. `BranchesRepository` still exists in both locations.

2. **Models in supabase_service.dart** — `BranchModel`, `ServiceModel`, `CustomerModel`, `OrderModel` are all defined at the bottom of `lib/shared/services/supabase_service.dart`. This is a 400+ line file.

3. **No real auth** — Google Sign-In populates the name field but doesn't create a persistent Supabase session. App identity is based on car plate + phone number.

4. **Empty domain/data layers** — `lib/domain/entities/`, `lib/domain/usecases/`, `lib/data/models/`, `lib/data/datasources/` are empty directories. Don't add files there unless explicitly planning to implement clean architecture.

5. **Tests are empty** — `test/widget_test.dart` contains only `void main() {}`. No test infrastructure is set up.

6. **`bloc` package listed but unused** — Despite being in `pubspec.yaml` dependencies, no BLoC/Cubit classes exist in the project. State is managed directly in StatefulWidgets.

7. **Build runner output not tracked** — After running `build_runner`, `.g.dart` files may already be in version control (they are in `lib/core/i18n/`). Don't re-commit them unless they changed.

8. **`withValues(alpha:)` API** — The codebase uses the newer Flutter `Color.withValues(alpha:)` API (not the older `withOpacity()`). This requires Flutter 3.27+/Dart 3.6+.

9. **`AnimatedBuilder` widget** — App uses the `animations` package's `AnimatedBuilder` (not Flutter's `AnimatedBuilder`). Import from `package:animations/animations.dart`.
