import 'package:flutter/material.dart';

/// Palette de couleurs inspirée de la culture Baoulé
/// Couleurs traditionnelles : Or, Noir, Blanc cassé, Rouge-orange
class BauleColors {
  // Couleurs primaires Baoulé
  static const Color gold = Color(0xFFD4AF37);        // Or classique
  static const Color darkGold = Color(0xFFC19A3B);    // Or foncé
  static const Color lightGold = Color(0xFFE8D5B7);   // Or clair/beige

  // Couleurs secondaires
  // NOTE: l'app ne doit pas tirer vers du "noir". On garde le nom historique
  // `deepBlack` mais on utilise un brun terre très foncé (lisible, chaleureux).
  static const Color deepBlack = Color(0xFF2B1B12);   // Brun terre (remplace le noir)
  static const Color creamWhite = Color(0xFFFAF7F2);  // Blanc cassé
  static const Color redOrange = Color(0xFFD84315);   // Rouge-orange traditionnel

  // Accents modernes (palette chaude "terre/orange")
  static const Color terreOrange = Color(0xFFD97706); // Orange terre
  static const Color burntOrange = Color(0xFFEA580C); // Orange brûlé
  static const Color forestGreen = Color(0xFF166534); // Vert profond

  // Accents
  static const Color accentGold = Color(0xFFFFD700);  // Accent or pur
  static const Color accentRed = Color(0xFFE53935);   // Accent rouge

  // Neutres
  static const Color darkText = Color(0xFF2C2C2C);
  static const Color lightText = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  // Dégradés
  static const LinearGradient bauleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2B1B12),      // Brun terre foncé
      Color(0xFF3B2416),      // Brun plus clair
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),      // Or classique
      Color(0xFFC19A3B),      // Or foncé
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFE8D5B7),
    ],
  );

  /// Assombrit légèrement une couleur pour les icônes/accents
  static Color darken(Color color, [double amount = .15]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Palette Baoulé complète pour le ThemeData
  static ThemeData bauleTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: deepBlack,
      scaffoldBackgroundColor: creamWhite,
      
      colorScheme: ColorScheme.light(
        primary: gold,
        secondary: redOrange,
        tertiary: darkGold,
        surface: creamWhite,
        background: creamWhite,
        error: redOrange,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: deepBlack,
        foregroundColor: creamWhite,
        elevation: 0,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: deepBlack,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineLarge: TextStyle(
          color: deepBlack,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: darkText,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: lightText,
          fontSize: 14,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        prefixIconColor: lightText,
        suffixIconColor: lightText,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: deepBlack,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
