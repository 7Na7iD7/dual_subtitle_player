import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/video_provider.dart';
import 'providers/subtitle_provider.dart';
import 'providers/cache_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'theme/modern_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => SubtitleProvider()),
        ChangeNotifierProvider(create: (_) => CacheProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Dual Subtitle Player',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: _getSelectedLightTheme(themeProvider.selectedThemeStyle),
            darkTheme: _getSelectedDarkTheme(themeProvider.selectedThemeStyle),
            home: const MainScreen(),
          );
        },
      ),
    );
  }

  ThemeData _getSelectedLightTheme(String style) {
    switch (style) {
      case 'glass':
        return ModernTheme.gradientLightTheme;
      case 'neon':
        return ModernTheme.gradientLightTheme;
      case 'gradient':
        return ModernTheme.gradientLightTheme;
      case 'classic':
      default:
        return AppTheme.lightTheme;
    }
  }

  ThemeData _getSelectedDarkTheme(String style) {
    switch (style) {
      case 'glass':
        return ModernTheme.glassDarkTheme;
      case 'neon':
        return ModernTheme.neonDarkTheme;
      case 'gradient':
        return ModernTheme.glassDarkTheme;
      case 'classic':
      default:
        return AppTheme.darkTheme;
    }
  }
}