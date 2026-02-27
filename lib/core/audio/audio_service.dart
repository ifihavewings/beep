/// ============================================================================
/// AudioService - Sound Playback Management
/// ============================================================================
/// 
/// **Design Principle:**
/// Singleton service that handles all audio playback in the app.
/// Abstracts the audioplayers package for easier testing and platform handling.
/// 
/// **Sound Types:**
/// 1. Chime sounds - Short notification sounds for hourly chimes
/// 2. Timer alerts - Sounds for custom timers
/// 
/// **Platform Considerations:**
/// - Web: Limited audio format support (MP3/WAV recommended)
/// - iOS: Requires audio session configuration for background playback
/// - Android: Works with most formats
/// ============================================================================
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Singleton service for audio playback
class AudioService {
  // Private constructor for singleton
  AudioService._();
  
  /// Global singleton instance
  static final AudioService instance = AudioService._();

  /// Audio player instance
  final AudioPlayer _player = AudioPlayer();

  /// Default chime sound asset path
  static const String _defaultChimeSound = 'sounds/chime.mp3';

  /// Default timer alert sound asset path
  static const String _defaultTimerSound = 'sounds/timer.mp3';

  /// Current volume level (0.0 to 1.0)
  double _volume = 1.0;

  /// Get current volume
  double get volume => _volume;

  /// Set volume level
  /// 
  /// [value] - Volume from 0.0 (mute) to 1.0 (max)
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  /// Play the hourly chime sound
  /// 
  /// Uses the default chime sound from assets.
  /// Falls back to system sound if asset not found.
  Future<void> playChime() async {
    try {
      await _player.setVolume(_volume);
      await _player.play(AssetSource(_defaultChimeSound));
      
      if (kDebugMode) {
        print('[AudioService] Playing chime sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioService] Error playing chime: $e');
      }
      // Fallback: Could use system notification sound
    }
  }

  /// Play the timer alert sound
  /// 
  /// Used when a custom timer completes.
  Future<void> playTimerAlert() async {
    try {
      await _player.setVolume(_volume);
      await _player.play(AssetSource(_defaultTimerSound));
      
      if (kDebugMode) {
        print('[AudioService] Playing timer alert');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioService] Error playing timer alert: $e');
      }
    }
  }

  /// Play a custom sound from assets
  /// 
  /// [assetPath] - Path to sound file in assets folder
  Future<void> playCustomSound(String assetPath) async {
    try {
      await _player.setVolume(_volume);
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print('[AudioService] Error playing custom sound: $e');
      }
    }
  }

  /// Stop any currently playing sound
  Future<void> stop() async {
    await _player.stop();
  }

  /// Dispose of audio resources
  /// 
  /// Call when app is closing to free resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
