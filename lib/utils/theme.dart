import 'package:flutter/material.dart';

class AppTheme {
  // ---------------------------------------------------------------------------
  // ☕ RENBO V3: Matcha & Mocha (Restored)
  // ---------------------------------------------------------------------------
  // The specific green you asked for
  static const Color matchaGreen = Color(0xFF628141);

  // Coffee Tones (Cooler, less yellow)
  static const Color espresso = Color(0xFF3E2723); // Dark Text
  static const Color cocoa = Color(0xFF8D6E63); // Secondary/Icons
  static const Color latteFoam = Color(0xFFFAF6F3); // Card Backgrounds
  static const Color oatMilk =
      Color(0xFFF2EBE5); // Main Background (Cool Beige)
  static const Color burntSienna = Color(0xFFA1887F); // Borders/Dividers
  static const Color errorRed = Color(0xFFBA1A1A);

  // ---------------------------------------------------------------------------
  // 🌉 THE BRIDGE (COMPATIBILITY FIX)
  // This maps the V9 names (used in your Journal) to your V3 colors.
  // ---------------------------------------------------------------------------
  static const Color coffeeButton = matchaGreen; // Maps 'coffeeButton' -> Green
  static const Color oatMilkBg = oatMilk; // Maps 'oatMilkBg' -> oatMilk
  static const Color espressoText = espresso; // Maps 'espressoText' -> espresso
  static const Color whiteIcon = Colors.white; // Maps 'whiteIcon' -> White

  // Old Aliases (Just in case)
  static const Color primaryColor = matchaGreen;
  static const Color secondaryColor = cocoa;
  static const Color darkGray = espresso;
  static const Color mediumGray = burntSienna;
  static const Color lightGray = oatMilk;

  // ---------------------------------------------------------------------------
  // 🖌️ THEME DATA
  // ---------------------------------------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',

    // 1. Backgrounds (Cool Oat Milk color)
    scaffoldBackgroundColor: oatMilk,
    canvasColor: oatMilk,

    // 2. Main Colors
    primaryColor: matchaGreen,
    colorScheme: const ColorScheme.light(
      primary: matchaGreen,
      onPrimary: Colors.white,
      secondary: cocoa,
      onSecondary: Colors.white,
      surface: latteFoam, // Cards are lighter than background
      onSurface: espresso,
      background: oatMilk,
      onBackground: espresso,
      error: errorRed,
    ),

    // 3. AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: oatMilk,
      elevation: 0,
      iconTheme: IconThemeData(color: espresso),
      titleTextStyle: TextStyle(
        color: espresso, // Dark coffee text for contrast
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),

    // 4. Buttons (Your Green #628141)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: matchaGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0, // Flat, modern look
        iconColor: Colors.white, // Ensures icons are white on green buttons
      ),
    ),

    // 5. Cards & Containers
    cardTheme: CardThemeData(
      color: latteFoam, // Soft white/cream
      elevation: 0, // Flat look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        // No border, just a clean soft card
      ),
    ),

    // 6. Text Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: latteFoam,
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none, // Clean input with no border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: matchaGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: cocoa),
      hintStyle: TextStyle(color: cocoa.withOpacity(0.5)),
    ),

    // 7. Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: espresso, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: espresso, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: espresso),
      bodyMedium: TextStyle(color: espresso),
      titleMedium: TextStyle(color: espresso, fontWeight: FontWeight.w600),
    ),

    // 8. Icon Theme
    iconTheme: const IconThemeData(
      color: cocoa,
    ),
  );
}
