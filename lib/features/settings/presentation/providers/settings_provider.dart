import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.fontScale,
    required this.notificationsEnabled,
  });

  final ThemeMode themeMode;
  final double fontScale;
  final bool notificationsEnabled;

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
    : super(
        const SettingsState(
          themeMode: ThemeMode.system,
          fontScale: 1,
          notificationsEnabled: true,
        ),
      ) {
    _load();
  }

  static const _themeKey = 'theme_mode';
  static const _fontScaleKey = 'font_scale';
  static const _notificationsKey = 'notifications_enabled';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeRaw = prefs.getString(_themeKey);
    final themeMode = ThemeMode.values.firstWhere(
      (item) => item.name == themeRaw,
      orElse: () => ThemeMode.system,
    );
    state = state.copyWith(
      themeMode: themeMode,
      fontScale: prefs.getDouble(_fontScaleKey) ?? 1,
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
  }

  Future<void> setNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }
}
