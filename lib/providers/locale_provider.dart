import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's language preference.
///
/// `null` means "follow system" — the app uses the device's locale if it's
/// supported, otherwise falls back to English.
class LocalePreference {
  const LocalePreference(this.code);

  /// The ISO 639-1 language code ('en', 'zh'), or null for system.
  final String? code;

  /// Resolves the preference to a concrete [Locale].
  ///
  /// When [code] is null, returns null so MaterialApp falls back to the
  /// system locale.
  Locale? toLocale() => code == null ? null : Locale(code!);
}

/// Notifier that manages the user's language preference.
///
/// Persists the choice to [SharedPreferences] so it survives app restarts.
/// On first launch, the preference is null (follow system).
class LocaleNotifier extends Notifier<LocalePreference> {
  static const _prefsKey = 'app_locale';

  @override
  LocalePreference build() {
    // Load the saved preference asynchronously.
    unawaited(_load());
    return const LocalePreference(null);
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null) {
        state = LocalePreference(code);
      }
    } catch (_) {
      // If SharedPreferences fails, default to system locale.
    }
  }

  /// Sets the language to [code] ('en' or 'zh'), or null for system.
  Future<void> setLanguage(String? code) async {
    state = LocalePreference(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (code == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setString(_prefsKey, code);
      }
    } catch (_) {
      // Persistence failure is non-fatal.
    }
  }
}

/// Provider that exposes the [LocaleNotifier].
final localeProvider =
    NotifierProvider<LocaleNotifier, LocalePreference>(LocaleNotifier.new);
