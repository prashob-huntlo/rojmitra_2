import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const localePrefsKey = 'app_locale';

class AppLocaleState {
  const AppLocaleState({
    this.isReady = false,
    this.hasSavedLanguage = false,
    this.locale,
  });

  final bool isReady;
  final bool hasSavedLanguage;
  final Locale? locale;
}

class LocaleNotifier extends Notifier<AppLocaleState> {
  @override
  AppLocaleState build() {
    _restore();
    return const AppLocaleState();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(localePrefsKey);
    if (code == null || code.isEmpty) {
      state = const AppLocaleState(isReady: true);
      return;
    }
    state = AppLocaleState(
      isReady: true,
      hasSavedLanguage: true,
      locale: Locale(code),
    );
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localePrefsKey, locale.languageCode);
    state = AppLocaleState(
      isReady: true,
      hasSavedLanguage: true,
      locale: locale,
    );
  }

  Future<void> useSystemDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(localePrefsKey);
    state = const AppLocaleState(isReady: true);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, AppLocaleState>(LocaleNotifier.new);
