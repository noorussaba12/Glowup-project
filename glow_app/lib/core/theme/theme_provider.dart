import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'glow_theme.dart';

class ThemeNotifier extends StateNotifier<GlowThemeMode> {
  static const _themePrefKey = 'glow_selected_theme_mode';

  ThemeNotifier() : super(GlowThemeMode.femalePink) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themePrefKey);
      if (savedMode == 'male') {
        state = GlowThemeMode.maleBlue;
      } else {
        state = GlowThemeMode.femalePink;
      }
    } catch (_) {}
  }

  Future<void> setTheme(GlowThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themePrefKey,
        mode == GlowThemeMode.maleBlue ? 'male' : 'female',
      );
    } catch (_) {}
  }

  void toggleTheme() {
    if (state == GlowThemeMode.femalePink) {
      setTheme(GlowThemeMode.maleBlue);
    } else {
      setTheme(GlowThemeMode.femalePink);
    }
  }

  GlowPalette get palette => state == GlowThemeMode.femalePink
      ? GlowPalette.female
      : GlowPalette.male;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, GlowThemeMode>((ref) {
  return ThemeNotifier();
});

final currentPaletteProvider = Provider<GlowPalette>((ref) {
  final mode = ref.watch(themeProvider);
  return mode == GlowThemeMode.femalePink ? GlowPalette.female : GlowPalette.male;
});
