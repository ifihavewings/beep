/// ============================================================================
/// SettingsScreen - User Preferences Configuration
/// ============================================================================
/// 
/// **Design Principle:**
/// Groups related settings into sections for easy navigation.
/// All changes are saved immediately (auto-save pattern).
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../state/settings_state.dart';

/// Settings configuration screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // ========================================
          // Hourly Chime Section
          // ========================================
          _buildSectionHeader(context, l10n.hourlyChime),
          
          SwitchListTile(
            title: Text(l10n.enableHourlyChime),
            subtitle: Text(l10n.enableHourlyChimeDesc),
            value: settings.hourlyChimeEnabled,
            onChanged: notifier.setHourlyChimeEnabled,
          ),

          ListTile(
            title: Text(l10n.quietHours),
            subtitle: Text(
              '${_formatHour(settings.quietHoursStart, l10n)} - ${_formatHour(settings.quietHoursEnd, l10n)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            enabled: settings.hourlyChimeEnabled,
            onTap: settings.hourlyChimeEnabled
                ? () => _showQuietHoursPicker(context, ref, settings, l10n)
                : null,
          ),

          const Divider(),

          // ========================================
          // Sound Section
          // ========================================
          _buildSectionHeader(context, l10n.notifications),

          ListTile(
            title: Text(l10n.volume),
            subtitle: Slider(
              value: settings.volume,
              onChanged: notifier.setVolume,
              divisions: 10,
              label: '${(settings.volume * 100).round()}%',
            ),
          ),

          SwitchListTile(
            title: Text(l10n.vibration),
            subtitle: Text(l10n.vibrationDesc),
            value: settings.vibrateEnabled,
            onChanged: notifier.setVibrateEnabled,
          ),

          const Divider(),

          // ========================================
          // Display Section
          // ========================================
          _buildSectionHeader(context, l10n.appearance),

          ListTile(
            title: Text(l10n.language),
            subtitle: Text(_getLanguageDisplayName(settings.localeCode, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, ref, settings, l10n),
          ),

          ListTile(
            title: Text(l10n.theme),
            subtitle: Text(_getThemeLabel(settings.themeMode, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref, settings, l10n),
          ),

          SwitchListTile(
            title: Text(l10n.use24HourFormat),
            subtitle: Text(l10n.use24HourFormatDesc),
            value: settings.use24HourFormat,
            onChanged: notifier.setUse24HourFormat,
          ),

          const Divider(),

          // ========================================
          // About Section
          // ========================================
          _buildSectionHeader(context, l10n.about),

          ListTile(
            title: Text(l10n.version),
            subtitle: const Text('1.1.0'),
          ),

          ListTile(
            title: const Text('Reset to Defaults'),
            textColor: Theme.of(context).colorScheme.error,
            onTap: () => _confirmReset(context, ref, l10n),
          ),
        ],
      ),
    );
  }

  /// Build a section header widget
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  /// Format hour for display
  String _formatHour(int hour, AppLocalizations l10n) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  /// Get theme mode label
  String _getThemeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
    }
  }

  /// Get display name for language code
  String _getLanguageDisplayName(String? localeCode, AppLocalizations l10n) {
    if (localeCode == null) return l10n.languageSystem;
    
    const languageNames = {
      'en': 'English',
      'zh': '简体中文',
      'zh-Hant': '繁體中文',
      'ja': '日本語',
      'ar': 'العربية',
      'fr': 'Français',
      'de': 'Deutsch',
      'es': 'Español',
      'it': 'Italiano',
      'pt': 'Português',
      'nl': 'Nederlands',
      'sv': 'Svenska',
      'no': 'Norsk',
      'da': 'Dansk',
      'fi': 'Suomi',
      'pl': 'Polski',
      'tr': 'Türkçe',
      'ru': 'Русский',
      'uk': 'Українська',
      'el': 'Ελληνικά',
      'hi': 'हिन्दी',
      'bn': 'বাংলা',
      'ta': 'தமிழ்',
      'te': 'తెలుగు',
      'mr': 'मराठी',
      'ur': 'اردو',
      'id': 'Bahasa Indonesia',
      'ms': 'Bahasa Melayu',
      'th': 'ไทย',
      'vi': 'Tiếng Việt',
      'fil': 'Filipino',
    };
    
    return languageNames[localeCode] ?? localeCode;
  }

  /// Show quiet hours picker dialog
  void _showQuietHoursPicker(
    BuildContext context,
    WidgetRef ref,
    settings,
    AppLocalizations l10n,
  ) {
    int startHour = settings.quietHoursStart;
    int endHour = settings.quietHoursEnd;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.quietHours),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.quietHoursDesc),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(l10n.startTime),
                      DropdownButton<int>(
                        value: startHour,
                        items: List.generate(24, (i) => i)
                            .map((h) => DropdownMenuItem(
                                  value: h,
                                  child: Text(_formatHour(h, l10n)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => startHour = value);
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(l10n.endTime),
                      DropdownButton<int>(
                        value: endHour,
                        items: List.generate(24, (i) => i)
                            .map((h) => DropdownMenuItem(
                                  value: h,
                                  child: Text(_formatHour(h, l10n)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => endHour = value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setQuietHours(start: startHour, end: endHour);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  /// Show language picker dialog
  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    settings,
    AppLocalizations l10n,
  ) {
    final languages = <String?, String>{
      null: l10n.languageSystem,
      'en': 'English',
      'zh': '简体中文',
      'zh-Hant': '繁體中文',
      'ja': '日本語',
      'ar': 'العربية',
      'fr': 'Français',
      'de': 'Deutsch',
      'es': 'Español',
      'it': 'Italiano',
      'pt': 'Português',
      'nl': 'Nederlands',
      'sv': 'Svenska',
      'no': 'Norsk',
      'da': 'Dansk',
      'fi': 'Suomi',
      'pl': 'Polski',
      'tr': 'Türkçe',
      'ru': 'Русский',
      'uk': 'Українська',
      'el': 'Ελληνικά',
      'hi': 'हिन्दी',
      'bn': 'বাংলা',
      'ta': 'தமிழ்',
      'te': 'తెలుగు',
      'mr': 'मराठी',
      'ur': 'اردو',
      'id': 'Bahasa Indonesia',
      'ms': 'Bahasa Melayu',
      'th': 'ไทย',
      'vi': 'Tiếng Việt',
      'fil': 'Filipino',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView(
            shrinkWrap: true,
            children: languages.entries.map((entry) {
              return RadioListTile<String?>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: settings.localeCode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setLocale(value);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Show theme picker dialog
  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    settings,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeLabel(mode, l10n)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Confirm reset to defaults
  void _confirmReset(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will reset all settings to their default values. '
          'Your timers will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
