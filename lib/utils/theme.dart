import 'package:flutter/material.dart';

class AppTheme {
  // ---------------------------------------------------------------------------
  // ☕ RENBO V3: Matcha & Mocha (Restored)
  // ---------------------------------------------------------------------------
  static const Color matchaGreen = Color(0xFF628141);

  // Light Theme Coffee Tones
  static const Color espresso = Color(0xFF3E2723); // Dark Text
  static const Color cocoa = Color(0xFF8D6E63); // Secondary/Icons
  static const Color latteFoam = Color(0xFFFAF6F3); // Card Backgrounds
  static const Color oatMilk = Color(0xFFF2EBE5); // Main Background
  static const Color burntSienna = Color(0xFFA1887F);
  static const Color errorRed = Color(0xFFBA1A1A);

  // ---------------------------------------------------------------------------
  // 🌙 Dark Theme Tones (Aesthetic Midnight Mocha)
  // ---------------------------------------------------------------------------
  // We use a deep charcoal-brown instead of pure black for a softer feel
  static const Color darkBackground = Color(0xFF1B1A17); 
  // Cards are slightly lighter to create depth/elevation
  static const Color darkSurface = Color(0xFF262421); 
  // Soft cream instead of pure white to reduce "halation" (glowing text effect)
  static const Color darkTextPrimary = Color(0xFFE5E0DA); 
  static const Color darkTextSecondary = Color(0xFFA8A29D); 
  // A slightly more vibrant green for dark mode to ensure accessibility
  static const Color darkMatcha = Color(0xFF7AA352); 

  // ---------------------------------------------------------------------------
  // 🌉 Compatibility Aliases
  // ---------------------------------------------------------------------------
  static const Color coffeeButton = matchaGreen;
  static const Color oatMilkBg = oatMilk;
  static const Color espressoText = espresso;
  static const Color whiteIcon = Colors.white;

  static const Color primaryColor = matchaGreen;
  static const Color secondaryColor = cocoa;
  static const Color darkGray = espresso;
  static const Color mediumGray = burntSienna;
  static const Color lightGray = oatMilk;

  // ---------------------------------------------------------------------------
  // 🌤️ LIGHT THEME
  // ---------------------------------------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',

    scaffoldBackgroundColor: oatMilk,
    canvasColor: oatMilk,

    colorScheme: const ColorScheme.light(
      primary: matchaGreen,
      onPrimary: Colors.white,
      secondary: cocoa,
      onSecondary: Colors.white,
      surface: latteFoam,
      onSurface: espresso,
      background: oatMilk,
      onBackground: espresso,
      error: errorRed,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: oatMilk,
      elevation: 0,
      iconTheme: IconThemeData(color: espresso),
      titleTextStyle: TextStyle(
        color: espresso,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: matchaGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0,
      ),
    ),

    cardTheme: CardThemeData(
      color: latteFoam,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: latteFoam,
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: matchaGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: cocoa),
      hintStyle: TextStyle(color: cocoa.withOpacity(0.5)),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: espresso, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: espresso, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: espresso, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: espresso),
      bodyMedium: TextStyle(color: espresso),
    ),

    iconTheme: const IconThemeData(color: cocoa),
  );

  // ---------------------------------------------------------------------------
  // 🌙 DARK THEME (Updated for better Aesthetics)
  // ---------------------------------------------------------------------------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',

    scaffoldBackgroundColor: darkBackground,
    canvasColor: darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: darkMatcha,      // Using slightly brighter green for contrast
      onPrimary: darkBackground, // Dark text on the green button
      secondary: Color.fromARGB(255, 253, 239, 234),
      onSecondary: Colors.white,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      background: darkBackground,
      onBackground: darkTextPrimary,
      error: errorRed,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextPrimary),
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkMatcha,
        foregroundColor: darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0,
      ),
    ),

    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 2, // Added slight elevation for shadow depth
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: darkMatcha, width: 2),
      ),
      labelStyle: const TextStyle(color: darkTextSecondary),
      hintStyle: TextStyle(color: darkTextSecondary.withOpacity(0.5)),
    ),

    textTheme: const TextTheme(
      displayLarge:
          TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
      titleLarge:
          TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
      titleMedium:
          TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: darkTextPrimary),
      bodyMedium: TextStyle(color: darkTextSecondary), // Muted for secondary info
    ),

    iconTheme: const IconThemeData(color: darkTextSecondary),
    dividerTheme: DividerThemeData(color: darkTextSecondary.withOpacity(0.2)),
  );
}