import 'package:flutter/material.dart';

class UtaColors {
  static const night = Color(0xFF130F24);
  static const plum = Color(0xFF211833);
  static const grape = Color(0xFF35204F);
  static const card = Color(0xFF241A36);
  static const cardSoft = Color(0xFF322344);
  static const passport = Color(0xFF6E49FF);
  static const sunset = Color(0xFFFF8A3D);
  static const gold = Color(0xFFFFD166);
  static const coral = Color(0xFFFF5C7A);
  static const mint = Color(0xFF56F0B2);
  static const sky = Color(0xFF7BDFF2);
  static const text = Color(0xFFFFFBF4);
  static const muted = Color(0xFFC7BACF);

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
  );

  static const label = TextStyle(
    color: UtaColors.muted,
    fontSize: 12,
    fontWeight: FontWeight.w700,
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
        seedColor: UtaColors.sunset,
        brightness: Brightness.dark,
        surface: UtaColors.plum,
        primary: UtaColors.sunset,
        secondary: UtaColors.passport,
        tertiary: UtaColors.gold,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: UtaColors.text,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        backgroundColor: UtaColors.plum,
        indicatorColor: UtaColors.grape,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? UtaColors.gold
                : UtaColors.muted,
            fontWeight: FontWeight.w900,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: UtaColors.cardSoft,
        selectedColor: UtaColors.passport,
        labelStyle: const TextStyle(color: UtaColors.text, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
