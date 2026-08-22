# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
# Dependencies
flutter pub get

# Run (pick a flavor)
flutter run --flavor development --target lib/main_development.dart
flutter run --flavor staging    --target lib/main_staging.dart
flutter run --flavor production --target lib/main_production.dart

# Code generation (run after adding/changing injectable, json_serializable, or assets)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # watch mode

# Tests
flutter test --coverage --test-randomize-ordering-seed random
flutter test test/features/counter/...  # single test file/dir

# Lint & format
dart analyze lib test
dart format --set-exit-if-changed lib test
dart fix --apply

# Combined pre-commit check
make prepare   # runs: fix → format → analyze

# Build artifacts
make apk-dev / apk-stg / apk-prod
make ipa-dev  / ipa-stg  / ipa-prod
```

Flutter is pinned to **3.41.6** via FVM (`.fvmrc`). Run with `fvm flutter` if using FVM locally.

## Architecture

Clean Architecture with three layers per feature, plus a `core/` and `shared/` cross-cutting layer.

### Layer responsibilities

| Layer | Location | What lives here |
|---|---|---|
| Data | `features/<f>/data/` | `datasources/` (network/local), `models/` (DTOs), `repositories/` (impls) |
| Domain | `features/<f>/domain/` | `entities/`, `repositories/` (interfaces), `usecases/` |
| Presentation | `features/<f>/presentation/` | `blocs/` (Cubits/Blocs), `pages/`, `widgets/` |

### Key files

- **Entry points**: `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart` — each calls `bootstrap()` with an environment string.
- **Bootstrap**: `lib/bootstrap.dart` — calls `configureDependencies`, sets up `AppBlocObserver`, runs the app.
- **DI**: `lib/injector.dart` + generated `lib/injector.config.dart` — GetIt + Injectable. Add `@injectable`/`@lazySingleton` annotations and re-run `build_runner` to register new services.
- **Router**: `lib/app/router/app_router.dart` — GoRouter; add new `GoRoute` entries here; use `AppRouter.<name>` constants for named navigation.
- **App root**: `lib/app/view/app.dart` — `MultiBlocProvider` (global blocs), `ScreenUtilInit`, `MaterialApp.router`, localization delegates.

### Error handling

- Use `Either<Failure, T>` (dartz) for all repository and use-case return types.
- `Failure` is a sealed class with `LocalFailure` and `ServerFailure` subtypes (`lib/core/domain/failures/failure.dart`).
- UI layer uses `FailureMessageHandler` mixin (`lib/core/presentation/mixins/`) to map failures to messages.

### State management

BLoC/Cubit via `flutter_bloc`. Global state (e.g., flash notifications) is provided at the app root via `MultiBlocProvider`. Feature-local Cubits are provided at the page/route level.

### Flash notifications

Call `context.displayFlash(message)` from anywhere in the widget tree — it dispatches to the global `FlashCubit` which drives a `SnackBar` listener in `app.dart`.

### Dependency injection modules

- `lib/core/di/app_module.dart` — app-wide singletons (e.g., router)
- `lib/core/di/storage_module.dart` — storage bindings
- Feature-level `@module` classes go inside the feature's `data/` folder.

### Localization

- Add strings to `lib/l10n/arb/app_en.arb` (and `app_id.arb` for Indonesian).
- Access via `context.l10n.<key>` (extension defined in `lib/core/extensions/context_extensions.dart`).
- Generated output is in `lib/l10n/generated/` — import from `package:template/l10n/generated/app_localizations.dart`, **not** from `flutter_gen`.

### Asset references

Generated constants in `lib/gen/assets.gen.dart` (via `flutter_gen`). Reference assets as `Assets.images.foo` instead of raw strings.

### Analysis

`analysis_options.yaml` extends `very_good_analysis`. Generated files (`*.g.dart`, `*.gen.dart`, `*.config.dart`) are excluded from analysis.
