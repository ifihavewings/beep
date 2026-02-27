/// ============================================================================
/// Beep - Cross-platform Hourly Chime & Timer Application
/// ============================================================================
///
/// **Design Principle:**
/// This is the application entry point. It initializes all necessary services
/// before the UI is rendered, ensuring a consistent state across the app.
///
/// **Architecture:**
/// - Uses Riverpod for state management (unidirectional data flow)
/// - Services are initialized asynchronously before app start
/// - All platforms (Android, iOS, macOS, Web) share the same codebase
///
/// **Key Components:**
/// 1. ProviderScope: Root of Riverpod state management
/// 2. SharedPreferences: Local storage for user settings
/// 3. NotificationService: System notifications for chimes and timers
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/background/background_service.dart';
import 'core/notification/notification_service.dart';
import 'ui/state/settings_state.dart';

void main() async {
  // Ensure Flutter bindings are initialized before any async operations
  // This is required for plugins that need platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for local storage
  // Used to persist user settings (quiet hours, timers, preferences)
  final prefs = await SharedPreferences.getInstance();

  // Initialize notification service for system notifications
  // Handles both hourly chimes and custom timer alerts
  await NotificationService.instance.initialize();

  // Initialize background service for Android
  // Enables foreground service and battery optimization exemption
  await BackgroundService.instance.initialize();

  // Run the app with Riverpod's ProviderScope
  // Override the SharedPreferences provider with the initialized instance
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const BeepApp(),
    ),
  );
}
