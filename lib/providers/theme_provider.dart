import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _selectedThemeStyle = 'glass';
  // glass, neon, gradient, classic

  ThemeMode get themeMode => _themeMode;
  String get selectedThemeStyle => _selectedThemeStyle;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? true;
      final style = prefs.getString('themeStyle') ?? 'glass';

      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _selectedThemeStyle = style;
      _updateSystemUI();
      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.dark;
      _selectedThemeStyle = 'glass';
    }
  }

  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);
      await prefs.setString('themeStyle', _selectedThemeStyle);
    } catch (e) {
    }
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _updateSystemUI();
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _updateSystemUI();
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setThemeStyle(String style) {
    _selectedThemeStyle = style;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void _updateSystemUI() {
    if (_themeMode == ThemeMode.dark) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }
  }

  String getThemeStyleName() {
    switch (_selectedThemeStyle) {
      case 'glass':
        return 'Glassmorphism';
      case 'neon':
        return 'Neon Cyber';
      case 'gradient':
        return 'Modern Gradient';
      case 'classic':
        return 'Classic';
      default:
        return 'Unknown';
    }
  }

  IconData getThemeStyleIcon() {
    switch (_selectedThemeStyle) {
      case 'glass':
        return Icons.blur_on;
      case 'neon':
        return Icons.flash_on;
      case 'gradient':
        return Icons.gradient;
      case 'classic':
        return Icons.palette;
      default:
        return Icons.color_lens;
    }
  }
}