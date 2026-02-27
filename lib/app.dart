/// ============================================================================
/// BeepApp - Application Root Widget
/// ============================================================================
/// 
/// **Design Principle:**
/// Centralized configuration for theming, localization, and routing.
/// Separating app configuration from main.dart improves testability.
/// 
/// **Features:**
/// - Material 3 design system
/// - System locale detection (default: English)
/// - Light/Dark theme support
/// - Responsive layout ready
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'ui/screens/home_screen.dart';
import 'ui/state/settings_state.dart';

/// Root widget of the Beep application
/// 
/// Uses ConsumerWidget to access Riverpod providers for reactive theming
class BeepApp extends ConsumerWidget {
  const BeepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch settings for theme changes
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      // App title shown in task switcher
      title: 'Beep',
      
      // Disable debug banner in release builds
      debugShowCheckedModeBanner: false,

      // ========================================
      // Theme Configuration
      // ========================================
      // Using Material 3 with a warm amber color scheme
      // Amber represents alertness and time (like alarm clocks)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Follow system theme by default, can be overridden by user preference
      themeMode: settings.themeMode,

      // ========================================
      // Localization Configuration
      // ========================================
      // User can override system locale in settings
      locale: _parseLocale(settings.localeCode),
      localizationsDelegates: const [
        AppLocalizations.delegate, // Custom app strings
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English (default)
        Locale('zh'), // Chinese Simplified
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), // Chinese Traditional
        Locale('ja'), // Japanese
        Locale('ar'), // Arabic
        // Europe - major languages
        Locale('fr'), // French
        Locale('de'), // German
        Locale('es'), // Spanish
        Locale('it'), // Italian
        Locale('pt'), // Portuguese
        Locale('nl'), // Dutch
        Locale('sv'), // Swedish
        Locale('no'), // Norwegian
        Locale('da'), // Danish
        Locale('fi'), // Finnish
        Locale('pl'), // Polish
        Locale('tr'), // Turkish
        Locale('ru'), // Russian
        Locale('uk'), // Ukrainian
        Locale('el'), // Greek
        // India - major languages
        Locale('hi'), // Hindi
        Locale('bn'), // Bengali
        Locale('ta'), // Tamil
        Locale('te'), // Telugu
        Locale('mr'), // Marathi
        Locale('ur'), // Urdu
        // Southeast Asia
        Locale('id'), // Indonesian
        Locale('ms'), // Malay
        Locale('th'), // Thai
        Locale('vi'), // Vietnamese
        Locale('fil'), // Filipino
      ],

      // ========================================
      // Navigation
      // ========================================
      home: const HomeScreen(),
    );
  }

  /// Parse locale code string to Locale object
  Locale? _parseLocale(String? localeCode) {
    if (localeCode == null) return null;
    
    // Handle script codes like 'zh-Hant'
    if (localeCode.contains('-')) {
      final parts = localeCode.split('-');
      if (parts.length == 2) {
        // Check if second part is script code (4 letters) or country code (2 letters)
        if (parts[1].length == 4) {
          return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
        } else {
          return Locale(parts[0], parts[1]);
        }
      }
    }
    return Locale(localeCode);
  }
}
