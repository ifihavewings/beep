/// ============================================================================
/// SettingsRepository - Local Storage for Settings
/// ============================================================================
/// 
/// **Design Principle:**
/// Repository pattern separates data access from business logic.
/// Uses SharedPreferences for simple key-value storage (no database needed).
/// 
/// **Why SharedPreferences:**
/// - Simple settings don't need SQLite overhead
/// - Cross-platform support (Android, iOS, macOS, Web)
/// - Synchronous read after initial async load
/// ============================================================================
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';
import '../models/timer_model.dart';

/// Storage keys
class StorageKeys {
  static const String settings = 'beep_settings';
  static const String timers = 'beep_timers';
}

/// Repository for persisting settings and timers
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // ========================================
  // Settings Operations
  // ========================================

  /// Load settings from storage
  /// 
  /// Returns default settings if nothing saved
  SettingsModel loadSettings() {
    final jsonString = _prefs.getString(StorageKeys.settings);
    if (jsonString == null) {
      return const SettingsModel(); // Return defaults
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SettingsModel.fromJson(json);
    } catch (e) {
      // If parsing fails, return defaults
      return const SettingsModel();
    }
  }

  /// Save settings to storage
  Future<void> saveSettings(SettingsModel settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(StorageKeys.settings, jsonString);
  }

  // ========================================
  // Timer Operations
  // ========================================

  /// Load all saved timers from storage
  List<TimerModel> loadTimers() {
    final jsonString = _prefs.getString(StorageKeys.timers);
    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => TimerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save all timers to storage
  Future<void> saveTimers(List<TimerModel> timers) async {
    final jsonList = timers.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(StorageKeys.timers, jsonString);
  }

  /// Add a single timer (convenience method)
  Future<void> addTimer(TimerModel timer) async {
    final timers = loadTimers();
    timers.add(timer);
    await saveTimers(timers);
  }

  /// Remove a timer by ID
  Future<void> removeTimer(String timerId) async {
    final timers = loadTimers();
    timers.removeWhere((t) => t.id == timerId);
    await saveTimers(timers);
  }

  /// Update a timer
  Future<void> updateTimer(TimerModel timer) async {
    final timers = loadTimers();
    final index = timers.indexWhere((t) => t.id == timer.id);
    if (index != -1) {
      timers[index] = timer;
      await saveTimers(timers);
    }
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAll() async {
    await _prefs.remove(StorageKeys.settings);
    await _prefs.remove(StorageKeys.timers);
  }
}
