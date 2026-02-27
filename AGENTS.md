# AGENTS.md - Beep Application Developer Guide

## Overview
Beep is a cross-platform Flutter application for hourly chimes and custom timers, supporting Android, iOS, macOS, and Web.

## Build Commands

```bash
# Run the app (debug mode)
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d macos
flutter run -d chrome  # Web

# Build for release
flutter build apk              # Android
flutter build ipa              # iOS (macOS only)
flutter build macos            # macOS
flutter build web              # Web

# Build numbers
flutter build apk --build-number=123
```

## Lint & Analysis

```bash
# Run static analysis
flutter analyze

# Run with specific lints
flutter analyze --no-fatal-infos
flutter analyze --no-fatal-warnings
```

## Testing

```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run tests matching a name pattern
flutter test --name="timer"

# Run tests in debug mode (with watchers)
flutter test --debug

# Run with code coverage
flutter test --coverage
```

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── app.dart                   # Root widget with theming/localization
├── core/                      # Core services
│   ├── audio/                 # Audio playback
│   ├── background/            # Background task handling
│   ├── notification/          # System notifications
│   └── scheduler/            # Chime scheduling logic
├── data/                      # Data layer
│   ├── models/                # Data models (immutable)
│   └── repositories/          # Data persistence
├── l10n/                      # Localization
└── ui/                        # Presentation layer
    ├── screens/               # Screen widgets
    ├── state/                 # Riverpod state management
    └── widgets/               # Reusable widgets
```

## Code Style Guidelines

### File Organization
- Use `library;` directive at top of each file
- One class per file (filename matches class name, snake_case)
- Group imports: Dart SDK → External packages → Internal packages

### Imports
```dart
// Correct order:
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/settings_model.dart';
import '../state/settings_state.dart';
```

### Naming Conventions
- **Classes/Enums**: PascalCase (`TimerModel`, `TimerRepeatMode`)
- **Functions/Variables**: camelCase (`isEnabled`, `targetTime`)
- **Constants**: camelCase with `k` prefix (`kDefaultTimeout`)
- **Files**: snake_case (`timer_model.dart`, `home_screen.dart`)
- **Private members**: prefix with `_` (`_clockTimer`, `_loadSettings`)

### Types & Annotations
- Use explicit return types on public functions
- Use `@immutable` annotation for data models
- Prefer `final` over `var`
- Use `const` constructors where possible

### Documentation
Every significant file should have a header comment block with:
```dart
/// ============================================================================
/// FileName - Short Description
/// ============================================================================
/// 
/// **Design Principle:**
/// Brief explanation of architectural decisions.
/// 
/// **Key Components:**
/// - Component 1: Purpose
/// - Component 2: Purpose
/// ============================================================================
```

Use ` comments///` (doc) for public APIs.

### Error Handling
- Use `StateError` for initialization errors
- Throw descriptive errors with context: `throw StateError('Service must be initialized')`
- Handle platform exceptions gracefully (use `kIsWeb` checks)
- Log errors before throwing when appropriate

### State Management (Riverpod)
- Use `StateNotifierProvider` for mutable state
- Use `Provider` for computed/derived values
- Use `ConsumerWidget` or `ConsumerStatefulWidget` for UI
- Providers must have explicit type annotations

```dart
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(repository),
);
```

### Data Models
- Make models `@immutable`
- Provide `copyWith()` for immutable updates
- Implement `fromJson()` / `toJson()` for serialization
- Override `==` and `hashCode` based on `id`

### Widgets
- Use `const` constructors where possible
- Extract reusable widgets to `lib/ui/widgets/`
- Follow single responsibility principle
- Use `SafeArea` for main scaffold body

### Services
- Use singleton pattern with private constructor for services
- Prefix instance with `instance`: `NotificationService.instance`
- Initialize asynchronously before app starts
- Document platform limitations

### Testing Conventions
- Test files in `test/` mirror `lib/` structure
- Use `testWidgets` for widget tests
- Mock providers using `ProviderScope(overrides: [...])`
- Name test files: `<feature>_test.dart`

## Platform-Specific Considerations

### Android
- Requires notification channel setup for Android 8.0+
- Background execution limited by Doze mode
- Use `androidScheduleMode.exactAllowWhileIdle` for precise timing

### iOS/macOS
- Request permissions at runtime
- Background notifications require entitlements
- Use `DarwinInitializationSettings` for iOS/macOS config

### Web
- Limited notification support (no custom sounds)
- Skip platform-specific initialization with `kIsWeb` check

## Key Dependencies

- `flutter_riverpod`: State management
- `shared_preferences`: Local storage
- `flutter_local_notifications`: System notifications
- `audioplayers`: Audio playback
- `intl`: Internationalization
- `uuid`: Unique ID generation
