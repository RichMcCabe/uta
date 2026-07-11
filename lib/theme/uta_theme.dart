import 'package:flutter/material.dart';

class UtaColors {
  static const night = Color(0xFF020A16);
  static const plum = Color(0xFF071525);
  static const grape = Color(0xFF0D2238);
  static const card = Color(0xFF0A1A2C);
  static const cardSoft = Color(0xFF102740);
  static const passport = Color(0xFF76A9FF);
  static const sunset = Color(0xFFE9AE3D);
  static const gold = Color(0xFFF3BD4F);
  static const coral = Color(0xFFFF7B7B);
  static const mint = Color(0xFF61D58A);
  static const sky = Color(0xFF8FC5FF);
  static const text = Color(0xFFF7F9FC);
  static const muted = Color(0xFFAAB7C8);

  static const amber = gold;
  static const green = mint;
  static const cyan = sky;
  static const blue = passport;
  static const deepOcean = plum;
  static const midnight = night;
}

class UtaText {
  static const hero = TextStyle(
    color: UtaColors.text,
    fontSize: 34,
    fontWeight: FontWeight.w900,
    height: 0.98,
    letterSpacing: -0.8,
  );

  static const title = TextStyle(
    color: UtaColors.text,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.25,
  );

  static const label = TextStyle(
    color: UtaColors.muted,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
  );

  static const value = TextStyle(
    color: UtaColors.text,
    fontSize: 17,
    fontWeight: FontWeight.w900,
  );
}

class UtaTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: UtaColors.night,
      colorScheme: ColorScheme.fromSeed(
        seedColor: UtaColors.gold,
        brightness: Brightness.dark,
        surface: UtaColors.plum,
        primary: UtaColors.gold,
        onPrimary: UtaColors.night,
        secondary: UtaColors.sky,
        tertiary: UtaColors.mint,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: UtaColors.text,
        displayColor: UtaColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: UtaColors.night,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: UtaColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: UtaColors.plum,
        indicatorColor: UtaColors.gold.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? UtaColors.gold
                : UtaColors.muted,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? UtaColors.gold
                : UtaColors.muted,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: UtaColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: UtaColors.gold,
          foregroundColor: UtaColors.night,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UtaColors.cardSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: UtaColors.gold),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: UtaColors.cardSoft,
        selectedColor: UtaColors.gold.withValues(alpha: 0.18),
        labelStyle: const TextStyle(color: UtaColors.text, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.08),
    );
  }
}
