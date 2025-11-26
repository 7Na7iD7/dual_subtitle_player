import 'package:flutter/material.dart';

class ModernTheme {

  static ThemeData glassDarkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    primaryColor: const Color(0xFF6366F1),
    scaffoldBackgroundColor: const Color(0xFF0A0A0F),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6366F1), // Indigo
      secondary: Color(0xFF8B5CF6), // Purple
      tertiary: Color(0xFFEC4899), // Pink
      surface: Color(0xFF1C1C24),
      background: Color(0xFF0A0A0F),
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFE8E8F0),
      onBackground: Color(0xFFE8E8F0),
      onError: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1C1C24).withOpacity(0.8),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Color(0xFFE8E8F0)),
      titleTextStyle: const TextStyle(
        color: Color(0xFFE8E8F0),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1C1C24).withOpacity(0.6),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    ),

    iconTheme: const IconThemeData(
      color: Color(0xFF6366F1),
      size: 24,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: Color(0xFFE8E8F0),
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: Color(0xFFE8E8F0),
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE8E8F0),
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE8E8F0),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE8E8F0),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFE8E8F0),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFB4B4C0),
        height: 1.5,
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: const Color(0xFF6366F1),
      inactiveTrackColor: const Color(0xFF2A2A38),
      thumbColor: const Color(0xFF6366F1),
      overlayColor: const Color(0xFF6366F1).withOpacity(0.3),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.08),
      thickness: 1,
    ),
  );

  static ThemeData neonDarkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    primaryColor: const Color(0xFF00FFF0),
    scaffoldBackgroundColor: const Color(0xFF000814),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00FFF0), // Cyan Neon
      secondary: Color(0xFFFF006E), // Magenta Neon
      tertiary: Color(0xFFFFBE0B), // Yellow Neon
      surface: Color(0xFF001D3D),
      background: Color(0xFF000814),
      error: Color(0xFFFF006E),
      onPrimary: Color(0xFF000814),
      onSecondary: Colors.white,
      onSurface: Color(0xFFF0F0F0),
      onBackground: Color(0xFFF0F0F0),
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF001D3D),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF00FFF0)),
      titleTextStyle: TextStyle(
        color: Color(0xFF00FFF0),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF001D3D),
      elevation: 0,
      shadowColor: const Color(0xFF00FFF0).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFF00FFF0),
          width: 2,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFF0),
        foregroundColor: const Color(0xFF000814),
        elevation: 12,
        shadowColor: const Color(0xFF00FFF0).withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),

    iconTheme: const IconThemeData(
      color: Color(0xFF00FFF0),
      size: 24,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        color: Color(0xFF00FFF0),
        letterSpacing: 1,
        shadows: [
          Shadow(
            color: Color(0xFF00FFF0),
            blurRadius: 20,
          ),
        ],
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Color(0xFFFFBE0B),
        letterSpacing: 0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF0F0F0),
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF0F0F0),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF0F0F0),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFF0F0F0),
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFB0B0C0),
        height: 1.5,
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: const Color(0xFF00FFF0),
      inactiveTrackColor: const Color(0xFF003566),
      thumbColor: const Color(0xFF00FFF0),
      overlayColor: const Color(0xFF00FFF0).withOpacity(0.3),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    dividerTheme: DividerThemeData(
      color: const Color(0xFF00FFF0).withOpacity(0.3),
      thickness: 1,
    ),
  );

  static ThemeData gradientLightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    primaryColor: const Color(0xFF6366F1),
    scaffoldBackgroundColor: const Color(0xFFFAFAFC),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF8B5CF6),
      tertiary: Color(0xFFEC4899),
      surface: Colors.white,
      background: Color(0xFFFAFAFC),
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1A1A1A),
      onBackground: Color(0xFF1A1A1A),
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 8,
      shadowColor: const Color(0xFF6366F1).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    ),

    iconTheme: const IconThemeData(
      color: Color(0xFF6366F1),
      size: 24,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF1A1A1A),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF64748B),
        height: 1.5,
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: const Color(0xFF6366F1),
      inactiveTrackColor: const Color(0xFFE2E8F0),
      thumbColor: const Color(0xFF6366F1),
      overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    dividerTheme: DividerThemeData(
      color: Colors.grey[200],
      thickness: 1,
    ),
  );


  // Glassmorphism Gradients
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glassCardGradient = LinearGradient(
    colors: [
      const Color(0xFF1C1C24).withOpacity(0.7),
      const Color(0xFF2A2A38).withOpacity(0.5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neon Gradients
  static const LinearGradient neonGradient = LinearGradient(
    colors: [
      Color(0xFF00FFF0),
      Color(0xFF00D9FF),
      Color(0xFF0080FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonPinkGradient = LinearGradient(
    colors: [
      Color(0xFFFF006E),
      Color(0xFFFF5FA2),
      Color(0xFFFFBE0B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Modern Gradients
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFF4ECDC4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [
      Color(0xFFFF0844),
      Color(0xFFFFB199),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [
      Color(0xFF11998E),
      Color(0xFF38EF7D),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [
      Color(0xFF7F00FF),
      Color(0xFFE100FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [
      Color(0xFF2196F3),
      Color(0xFF00BCD4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shimmer Gradients (for loading states)
  static LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Colors.grey[300]!,
      Colors.grey[100]!,
      Colors.grey[300]!,
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient darkShimmerGradient = LinearGradient(
    colors: [
      const Color(0xFF2A2A38),
      const Color(0xFF3A3A48),
      const Color(0xFF2A2A38),
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  static BoxDecoration glassBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        const Color(0xFF1C1C24).withOpacity(0.7),
        const Color(0xFF2A2A38).withOpacity(0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF6366F1).withOpacity(0.2),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration neonBoxDecoration = BoxDecoration(
    color: const Color(0xFF001D3D),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: const Color(0xFF00FFF0),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF00FFF0).withOpacity(0.5),
        blurRadius: 30,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration gradientBoxDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF6366F1).withOpacity(0.4),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
    ],
  );


  static TextStyle gradientTextStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
    );
  }

  static TextStyle neonTextStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: const Color(0xFF00FFF0),
      shadows: const [
        Shadow(
          color: Color(0xFF00FFF0),
          blurRadius: 20,
        ),
        Shadow(
          color: Color(0xFF00FFF0),
          blurRadius: 40,
        ),
      ],
    );
  }
}