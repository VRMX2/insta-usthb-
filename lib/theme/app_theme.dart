import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Revolutionary Quantum Glassmorphism Theme
/// Features floating glass elements, holographic accents, and ethereal depth
class AppTheme {
  AppTheme._();

  // Quantum Spectrum Palette - Otherworldly colors with holographic depth
  static const Color primaryLight = Color(0xFF6366F1); // Ethereal indigo
  static const Color primaryVariantLight = Color(0xFF4338CA);
  static const Color secondaryLight = Color(0xFF10B981); // Quantum emerald
  static const Color secondaryVariantLight = Color(0xFF059669);
  static const Color accentLight = Color(0xFFFF007F); // Neon magenta
  static const Color backgroundLight = Color(0xFFF8FAFC); // Crystalline white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure glass
  static const Color errorLight = Color(0xFFEF4444); // Energy red
  static const Color successLight = Color(0xFF22C55E); // Success pulse
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF0F172A); // Deep space
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  // Dark mode - Deep space with aurora effects
  static const Color primaryDark = Color(0xFF818CF8); // Aurora violet
  static const Color primaryVariantDark = Color(0xFF6366F1);
  static const Color secondaryDark = Color(0xFF34D399); // Plasma green
  static const Color secondaryVariantDark = Color(0xFF10B981);
  static const Color accentDark = Color(0xFFFF6B9D); // Soft neon pink
  static const Color backgroundDark = Color(0xFF0C0C0D); // Void black
  static const Color surfaceDark = Color(0xFF1A1B23); // Glass panel
  static const Color errorDark = Color(0xFFF87171); // Soft error glow
  static const Color successDark = Color(0xFF4ADE80); // Success aurora
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFE2E8F0);
  static const Color onSurfaceDark = Color(0xFFE2E8F0);
  static const Color onErrorDark = Color(0xFF000000);

  // Holographic glass surfaces
  static const Color glassLight = Color(0xFFFFFFFF);
  static const Color glassDark = Color(0xFF1E293B);

  // Quantum shadows and glows
  static const Color quantumShadowLight = Color(0x1A6366F1);
  static const Color quantumShadowDark = Color(0x3D818CF8);

  // Ethereal borders and dividers
  static const Color etherealBorderLight = Color(0xFFE2E8F0);
  static const Color etherealBorderDark = Color(0xFF334155);
  static const Color hologramDividerLight = Color(0xFFCBD5E1);
  static const Color hologramDividerDark = Color(0xFF475569);

  // Quantum text hierarchy
  static const Color textQuantumLight = Color(0xFF0F172A);
  static const Color textNebulaLight = Color(0xFF475569);
  static const Color textGhostLight = Color(0xFF94A3B8);

  static const Color textQuantumDark = Color(0xFFE2E8F0);
  static const Color textNebulaDark = Color(0xFFCBD5E1);
  static const Color textGhostDark = Color(0xFF94A3B8);

  /// Light theme - Crystalline Dimension
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryLight.withOpacity(0.1),
      onPrimaryContainer: primaryVariantLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryLight.withOpacity(0.1),
      onSecondaryContainer: secondaryVariantLight,
      tertiary: accentLight,
      onTertiary: onPrimaryLight,
      tertiaryContainer: accentLight.withOpacity(0.1),
      onTertiaryContainer: accentLight,
      error: errorLight,
      onError: onErrorLight,
      errorContainer: errorLight.withOpacity(0.1),
      onErrorContainer: errorLight,
      outline: etherealBorderLight,
      outlineVariant: hologramDividerLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      surfaceVariant: backgroundLight,
      onSurfaceVariant: textNebulaLight,
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: primaryDark,
      shadow: quantumShadowLight,
      scrim: Colors.black26,
    ),
    scaffoldBackgroundColor: backgroundLight,
    dividerColor: hologramDividerLight,

    // Floating Glass AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight.withOpacity(0.8),
      foregroundColor: textQuantumLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: quantumShadowLight,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textQuantumLight,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(
        color: textQuantumLight,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: textQuantumLight,
        size: 24,
      ),
    ),

    // Quantum Holographic Drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: glassLight.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      shadowColor: quantumShadowLight,
      elevation: 24.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32.0),
          bottomRight: Radius.circular(32.0),
        ),
      ),
    ),

    // Interdimensional Navigation Rail
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surfaceLight.withOpacity(0.9),
      elevation: 16.0,
      selectedIconTheme: const IconThemeData(
        color: primaryLight,
        size: 28,
      ),
      unselectedIconTheme: const IconThemeData(
        color: textNebulaLight,
        size: 24,
      ),
      selectedLabelTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: primaryLight,
        letterSpacing: 0.8,
      ),
      unselectedLabelTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textNebulaLight,
        letterSpacing: 0.5,
      ),
      useIndicator: true,
      indicatorColor: primaryLight.withOpacity(0.15),
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),

    // Holographic Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight.withOpacity(0.95),
      selectedItemColor: primaryLight,
      unselectedItemColor: textNebulaLight,
      elevation: 20.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
    ),

    // Quantum Pulse FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentLight,
      foregroundColor: onPrimaryLight,
      elevation: 12.0,
      highlightElevation: 16.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    ),

    // Ethereal Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        elevation: 8.0,
        shadowColor: quantumShadowLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        side: const BorderSide(color: etherealBorderLight, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Quantum Typography
    textTheme: _buildQuantumTextTheme(isLight: true),

    // Holographic Input Fields
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight.withOpacity(0.6),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: etherealBorderLight, width: 1.5),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: etherealBorderLight, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: primaryLight, width: 2.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: errorLight, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: errorLight, width: 2.5),
      ),
      labelStyle: GoogleFonts.spaceGrotesk(
        color: textNebulaLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      hintStyle: GoogleFonts.spaceGrotesk(
        color: textGhostLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
      errorStyle: GoogleFonts.spaceGrotesk(
        color: errorLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    ),

    // Quantum Controls
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return Colors.grey[300];
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight.withOpacity(0.4);
        }
        return Colors.grey[300];
      }),
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(onPrimaryLight),
      side: const BorderSide(color: etherealBorderLight, width: 2.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return textNebulaLight;
      }),
    ),

    // Quantum Progress
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: etherealBorderLight,
      circularTrackColor: etherealBorderLight,
    ),

    // Ethereal Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      thumbColor: primaryLight,
      overlayColor: primaryLight.withOpacity(0.2),
      inactiveTrackColor: etherealBorderLight,
      valueIndicatorColor: primaryLight,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
    ),

    // Quantum Chip Design
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight.withOpacity(0.8),
      selectedColor: primaryLight.withOpacity(0.2),
      secondarySelectedColor: secondaryLight.withOpacity(0.2),
      shadowColor: quantumShadowLight,
      selectedShadowColor: quantumShadowLight,
      showCheckmark: true,
      checkmarkColor: primaryLight,
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      side: const BorderSide(color: etherealBorderLight, width: 1.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      brightness: Brightness.light,
      labelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textQuantumLight,
        letterSpacing: 0.3,
      ),
      secondaryLabelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textNebulaLight,
        letterSpacing: 0.4,
      ),
      elevation: 4.0,
    ),

    // Quantum Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textQuantumLight.withOpacity(0.95),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        boxShadow: [
          BoxShadow(
            color: quantumShadowLight,
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: GoogleFonts.spaceGrotesk(
        color: surfaceLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Ethereal Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textQuantumLight.withOpacity(0.95),
      contentTextStyle: GoogleFonts.spaceGrotesk(
        color: surfaceLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      actionTextColor: accentLight,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      elevation: 12.0,
    ),

    // Quantum Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: glassLight,
      elevation: 24.0,
      shadowColor: quantumShadowLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28.0)),
      ),
      titleTextStyle: GoogleFonts.orbitron(
        color: textQuantumLight,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      contentTextStyle: GoogleFonts.spaceGrotesk(
        color: textNebulaLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
    ),
  );

  /// Dark theme - Deep Space Aurora
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryDark.withOpacity(0.2),
      onPrimaryContainer: primaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryDark.withOpacity(0.2),
      onSecondaryContainer: secondaryDark,
      tertiary: accentDark,
      onTertiary: onPrimaryDark,
      tertiaryContainer: accentDark.withOpacity(0.2),
      onTertiaryContainer: accentDark,
      error: errorDark,
      onError: onErrorDark,
      errorContainer: errorDark.withOpacity(0.2),
      onErrorContainer: errorDark,
      outline: etherealBorderDark,
      outlineVariant: hologramDividerDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      surfaceVariant: backgroundDark,
      onSurfaceVariant: textNebulaDark,
      inverseSurface: surfaceLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: primaryLight,
      shadow: quantumShadowDark,
      scrim: Colors.black54,
    ),
    scaffoldBackgroundColor: backgroundDark,
    dividerColor: hologramDividerDark,

    // Aurora Glass AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark.withOpacity(0.8),
      foregroundColor: textQuantumDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: quantumShadowDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textQuantumDark,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(
        color: textQuantumDark,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: textQuantumDark,
        size: 24,
      ),
    ),

    // Deep Space Holographic Drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: glassDark.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      shadowColor: quantumShadowDark,
      elevation: 32.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32.0),
          bottomRight: Radius.circular(32.0),
        ),
      ),
    ),

    // Interdimensional Aurora Navigation Rail
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surfaceDark.withOpacity(0.9),
      elevation: 20.0,
      selectedIconTheme: const IconThemeData(
        color: primaryDark,
        size: 28,
      ),
      unselectedIconTheme: const IconThemeData(
        color: textNebulaDark,
        size: 24,
      ),
      selectedLabelTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: primaryDark,
        letterSpacing: 0.8,
      ),
      unselectedLabelTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textNebulaDark,
        letterSpacing: 0.5,
      ),
      useIndicator: true,
      indicatorColor: primaryDark.withOpacity(0.2),
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),

    // Aurora Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark.withOpacity(0.95),
      selectedItemColor: primaryDark,
      unselectedItemColor: textNebulaDark,
      elevation: 20.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
    ),

    // Neon Pulse FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentDark,
      foregroundColor: onPrimaryDark,
      elevation: 16.0,
      highlightElevation: 20.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    ),

    // Plasma Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryDark,
        backgroundColor: primaryDark,
        elevation: 12.0,
        shadowColor: quantumShadowDark,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        side: const BorderSide(color: etherealBorderDark, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Quantum Typography
    textTheme: _buildQuantumTextTheme(isLight: false),

    // Plasma Input Fields
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceDark.withOpacity(0.8),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: etherealBorderDark, width: 1.5),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: etherealBorderDark, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: primaryDark, width: 2.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: errorDark, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: errorDark, width: 2.5),
      ),
      labelStyle: GoogleFonts.spaceGrotesk(
        color: textNebulaDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      hintStyle: GoogleFonts.spaceGrotesk(
        color: textGhostDark,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
      errorStyle: GoogleFonts.spaceGrotesk(
        color: errorDark,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    ),

    // Aurora Controls
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryDark;
        }
        return Colors.grey[600];
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryDark.withOpacity(0.4);
        }
        return Colors.grey[600];
      }),
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(onPrimaryDark),
      side: const BorderSide(color: etherealBorderDark, width: 2.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryDark;
        }
        return textNebulaDark;
      }),
    ),

    // Plasma Progress
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearTrackColor: etherealBorderDark,
      circularTrackColor: etherealBorderDark,
    ),

    // Aurora Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryDark,
      thumbColor: primaryDark,
      overlayColor: primaryDark.withOpacity(0.3),
      inactiveTrackColor: etherealBorderDark,
      valueIndicatorColor: primaryDark,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
    ),

    // Aurora Chip Design
    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark.withOpacity(0.8),
      selectedColor: primaryDark.withOpacity(0.25),
      secondarySelectedColor: secondaryDark.withOpacity(0.25),
      shadowColor: quantumShadowDark,
      selectedShadowColor: quantumShadowDark,
      showCheckmark: true,
      checkmarkColor: primaryDark,
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      side: const BorderSide(color: etherealBorderDark, width: 1.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      brightness: Brightness.dark,
      labelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textQuantumDark,
        letterSpacing: 0.3,
      ),
      secondaryLabelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textNebulaDark,
        letterSpacing: 0.4,
      ),
      elevation: 6.0,
    ),

    // Plasma Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textQuantumDark.withOpacity(0.95),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        boxShadow: [
          BoxShadow(
            color: quantumShadowDark,
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      textStyle: GoogleFonts.spaceGrotesk(
        color: surfaceDark,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Aurora Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textQuantumDark.withOpacity(0.95),
      contentTextStyle: GoogleFonts.spaceGrotesk(
        color: surfaceDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      actionTextColor: accentDark,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      elevation: 16.0,
    ),

    // Deep Space Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: glassDark,
      elevation: 32.0,
      shadowColor: quantumShadowDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28.0)),
      ),
      titleTextStyle: GoogleFonts.orbitron(
        color: textQuantumDark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      contentTextStyle: GoogleFonts.spaceGrotesk(
        color: textNebulaDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
    ),
  );

  /// Revolutionary Quantum Typography System
  /// Uses Orbitron for futuristic headings and Space Grotesk for readable body text
  static TextTheme _buildQuantumTextTheme({required bool isLight}) {
    final Color textPrimary = isLight ? textQuantumLight : textQuantumDark;
    final Color textSecondary = isLight ? textNebulaLight : textNebulaDark;
    final Color textTertiary = isLight ? textGhostLight : textGhostDark;

    return TextTheme(
      // Display styles - Orbitron for futuristic impact
      displayLarge: GoogleFonts.orbitron(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: textPrimary,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 52,
        fontWeight: FontWeight.w900,
        color: textPrimary,
        letterSpacing: -0.8,
        height: 1.1,
      ),
      displaySmall: GoogleFonts.orbitron(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.6,
        height: 1.2,
      ),

      // Headline styles - Orbitron for commanding presence
      headlineLarge: GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      headlineSmall: GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.3,
      ),

      // Title styles - Space Grotesk for elegant hierarchy
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.2,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.3,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.4,
        height: 1.4,
      ),

      // Body styles - Space Grotesk for optimal readability
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.2,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.3,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.4,
        height: 1.4,
      ),

      // Label styles - Space Grotesk for UI elements
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
        height: 1.3,
      ),
      labelMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.6,
        height: 1.3,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.8,
        height: 1.2,
      ),
    );
  }

  /// Quantum Color Extensions for dynamic theming
  static Color getQuantumShadow(bool isDark) {
    return isDark ? quantumShadowDark : quantumShadowLight;
  }

  static Color getEtherealBorder(bool isDark) {
    return isDark ? etherealBorderDark : etherealBorderLight;
  }

  static Color getHologramDivider(bool isDark) {
    return isDark ? hologramDividerDark : hologramDividerLight;
  }

  static Color getGlassSurface(bool isDark) {
    return isDark ? glassDark : glassLight;
  }

  /// Quantum Animation Durations
  static const Duration quantumFast = Duration(milliseconds: 200);
  static const Duration quantumMedium = Duration(milliseconds: 300);
  static const Duration quantumSlow = Duration(milliseconds: 500);
  static const Duration quantumEpic = Duration(milliseconds: 800);

  /// Quantum Border Radius Presets
  static const BorderRadius quantumSmall = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius quantumMediums = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius quantumLarge = BorderRadius.all(Radius.circular(24.0));
  static const BorderRadius quantumXLarge = BorderRadius.all(Radius.circular(32.0));

  /// Quantum Elevation Levels
  static const double elevationFloat = 4.0;
  static const double elevationHover = 8.0;
  static const double elevationModal = 16.0;
  static const double elevationQuantum = 24.0;
  static const double elevationWarp = 32.0;

  /// Interdimensional Gradient Presets
  static const LinearGradient quantumPulse = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryLight,
      secondaryLight,
      accentLight,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient auroraDream = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDark,
      secondaryDark,
      accentDark,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const RadialGradient holoSphere = RadialGradient(
    center: Alignment.center,
    radius: 1.2,
    colors: [
      primaryLight,
      Colors.transparent,
    ],
    stops: [0.3, 1.0],
  );

  static const SweepGradient cosmicVortex = SweepGradient(
    center: Alignment.center,
    colors: [
      primaryLight,
      secondaryLight,
      accentLight,
      primaryLight,
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
  );

  /// Quantum Box Shadow Presets
  static List<BoxShadow> getQuantumGlow(bool isDark, {double intensity = 1.0}) {
    final Color shadowColor = isDark ? quantumShadowDark : quantumShadowLight;
    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.15 * intensity),
        blurRadius: 20.0 * intensity,
        offset: Offset(0, 8.0 * intensity),
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.1 * intensity),
        blurRadius: 40.0 * intensity,
        offset: Offset(0, 16.0 * intensity),
      ),
    ];
  }

  static List<BoxShadow> getEtherealFloat(bool isDark) {
    final Color shadowColor = isDark ? quantumShadowDark : quantumShadowLight;
    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.08),
        blurRadius: 12.0,
        offset: const Offset(0, 4.0),
      ),
    ];
  }

  static List<BoxShadow> getHolographicDepth(bool isDark) {
    final Color shadowColor = isDark ? quantumShadowDark : quantumShadowLight;
    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.2),
        blurRadius: 32.0,
        offset: const Offset(0, 12.0),
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.05),
        blurRadius: 64.0,
        offset: const Offset(0, 24.0),
      ),
    ];
  }
}