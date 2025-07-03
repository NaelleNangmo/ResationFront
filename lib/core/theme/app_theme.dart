import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thème professionnel de l'application avec design moderne
/// Utilise uniquement Material Design et Google Fonts (pas d'assets locaux)
class AppTheme {
  // Palette de couleurs professionnelle
  static const Color primaryColor = Color(0xFF2563EB);      // Bleu professionnel
  static const Color primaryVariant = Color(0xFF1D4ED8);    // Bleu foncé
  static const Color secondaryColor = Color(0xFF10B981);    // Vert succès
  static const Color accentColor = Color(0xFF8B5CF6);       // Violet accent
  
  // Couleurs d'état
  static const Color errorColor = Color(0xFFEF4444);        // Rouge erreur
  static const Color warningColor = Color(0xFFF59E0B);      // Orange warning
  static const Color successColor = Color(0xFF10B981);      // Vert succès
  static const Color infoColor = Color(0xFF3B82F6);         // Bleu info
  
  // Couleurs neutres pour un design épuré
  static const Color backgroundColor = Color(0xFFF8FAFC);   // Gris très clair
  static const Color surfaceColor = Colors.white;           // Blanc pur
  static const Color cardColor = Colors.white;              // Blanc pour cartes
  static const Color dividerColor = Color(0xFFE2E8F0);     // Gris divider
  
  // Couleurs de texte hiérarchisées
  static const Color textPrimary = Color(0xFF1E293B);       // Noir principal
  static const Color textSecondary = Color(0xFF64748B);     // Gris moyen
  static const Color textTertiary = Color(0xFF94A3B8);      // Gris clair
  static const Color textDisabled = Color(0xFFCBD5E1);      // Gris désactivé
  
  // Couleurs de statut pour les réservations
  static const Color statusActive = Color(0xFF10B981);      // Vert actif
  static const Color statusPending = Color(0xFFF59E0B);     // Orange en attente
  static const Color statusCancelled = Color(0xFFEF4444);   // Rouge annulé
  static const Color statusCompleted = Color(0xFF6B7280);   // Gris terminé
  
  /// Thème clair principal - utilise uniquement Material Design
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Schéma de couleurs Material 3
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFDEEAFF),
        onPrimaryContainer: Color(0xFF001D36),
        
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFD1FAE5),
        onSecondaryContainer: Color(0xFF002114),
        
        tertiary: accentColor,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFEDE9FE),
        onTertiaryContainer: Color(0xFF2D1B69),
        
        error: errorColor,
        onError: Colors.white,
        errorContainer: Color(0xFFFFEDEA),
        onErrorContainer: Color(0xFF410E0B),
        
        background: backgroundColor,
        onBackground: textPrimary,
        surface: surfaceColor,
        onSurface: textPrimary,
        surfaceVariant: Color(0xFFF1F5F9),
        onSurfaceVariant: textSecondary,
        
        outline: dividerColor,
        outlineVariant: Color(0xFFE2E8F0),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF2F3349),
        onInverseSurface: Color(0xFFF1F5F9),
        inversePrimary: Color(0xFFB6CCFF),
      ),
      
      // Configuration de l'AppBar moderne
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: textSecondary,
          size: 24,
        ),
      ),
      
      // Style des cartes avec ombres subtiles
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      
      // Boutons élevés avec style moderne
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(120, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Boutons de contour élégants
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(120, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Boutons texte subtils
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      
      // Champs de saisie modernes
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        
        // Bordures par défaut
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        
        // Styles de texte
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: textTertiary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: const TextStyle(
          color: errorColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        
        // Icônes Material Design intégrées
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      
      // Typographie hiérarchisée et lisible - utilise la police système par défaut
      textTheme: const TextTheme(
        // Titres principaux
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.0,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        
        // Titres de section
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
          height: 1.4,
        ),
        
        // Titres de cartes et composants
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.2,
          height: 1.4,
        ),
        
        // Texte de contenu
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.2,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.2,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.3,
          height: 1.5,
        ),
        
        // Labels et boutons
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textTertiary,
          letterSpacing: 0.5,
          height: 1.4,
        ),
      ),
      
      // Icônes Material Design intégrées
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Dividers subtils
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // Navigation bottom moderne
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // FAB avec style cohérent
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Chips modernes
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: primaryColor.withOpacity(0.1),
        disabledColor: const Color(0xFFE2E8F0),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Snackbars élégantes
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Dialogs modernes
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  
  /// Thème sombre (pour usage futur)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: Color(0xFF0F172A),
        surface: Color(0xFF1E293B),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
    );
  }
  
  /// Couleurs personnalisées pour les statuts
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'disponible':
        return statusActive;
      case 'pending':
      case 'en_attente':
        return statusPending;
      case 'cancelled':
      case 'annulee':
        return statusCancelled;
      case 'completed':
      case 'terminee':
        return statusCompleted;
      case 'hors_service':
        return errorColor;
      case 'maintenance':
        return warningColor;
      default:
        return textSecondary;
    }
  }
  
  /// Gradients pour les éléments visuels
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [successColor, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Ombres personnalisées
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}