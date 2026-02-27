/// ============================================================================
/// SettingsState - Riverpod State Management for Settings
/// ============================================================================
/// 
/// **Design Principle:**
/// Uses Riverpod's StateNotifier for reactive state management.
/// Changes to settings automatically trigger UI rebuilds.
/// 
/// **Data Flow:**
/// UI -> SettingsNotifier.updateXXX() -> Repository.save() -> UI rebuild
/// ============================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/settings_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/scheduler/chime_scheduler.dart';
import '../../core/audio/audio_service.dart';

/// Provider for SharedPreferences - must be overridden in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for SettingsRepository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

/// Provider for settings state
/// 
/// Automatically persists changes to local storage
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) {
    final repository = ref.watch(settingsRepositoryProvider);
    return SettingsNotifier(repository);
  },
);

/// StateNotifier for managing settings
/// 
/// Handles loading, updating, and persisting user settings
class SettingsNotifier extends StateNotifier<SettingsModel> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const SettingsModel()) {
    // Load saved settings on initialization
    _loadSettings();
  }

  /// Load settings from storage
  void _loadSettings() {
    state = _repository.loadSettings();
    
    // Apply loaded settings to services
    _applySettings();
  }

  /// Apply current settings to relevant services
  void _applySettings() {
    // Update chime scheduler
    if (state.hourlyChimeEnabled) {
      ChimeScheduler.instance.start(
        quietStart: state.quietHoursStart,
        quietEnd: state.quietHoursEnd,
      );
    } else {
      ChimeScheduler.instance.stop();
    }

    // Update audio volume
    AudioService.instance.setVolume(state.volume);
  }

  // ========================================
  // Settings Update Methods
  // ========================================

  /// Toggle hourly chime on/off
  Future<void> setHourlyChimeEnabled(bool enabled) async {
    state = state.copyWith(hourlyChimeEnabled: enabled);
    await _repository.saveSettings(state);
    
    if (enabled) {
      ChimeScheduler.instance.start(
        quietStart: state.quietHoursStart,
        quietEnd: state.quietHoursEnd,
      );
    } else {
      ChimeScheduler.instance.stop();
    }
  }

  /// Update quiet hours range
  Future<void> setQuietHours({
    required int start,
    required int end,
  }) async {
    state = state.copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
    );
    await _repository.saveSettings(state);
    
    ChimeScheduler.instance.setQuietHours(start: start, end: end);
  }

  /// Update volume level
  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _repository.saveSettings(state);
    
    await AudioService.instance.setVolume(volume);
  }

  /// Toggle vibration
  Future<void> setVibrateEnabled(bool enabled) async {
    state = state.copyWith(vibrateEnabled: enabled);
    await _repository.saveSettings(state);
  }

  /// Update theme mode
  Future<void> setThemeMode(themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _repository.saveSettings(state);
  }

  /// Toggle 24-hour format
  Future<void> setUse24HourFormat(bool use24Hour) async {
    state = state.copyWith(use24HourFormat: use24Hour);
    await _repository.saveSettings(state);
  }

  /// Set locale (null means follow system)
  Future<void> setLocale(String? localeCode) async {
    if (localeCode == null) {
      state = state.copyWith(clearLocale: true);
    } else {
      state = state.copyWith(localeCode: localeCode);
    }
    await _repository.saveSettings(state);
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    state = const SettingsModel();
    await _repository.saveSettings(state);
    _applySettings();
  }
}
