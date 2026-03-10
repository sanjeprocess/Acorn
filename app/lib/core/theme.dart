import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Light Theme Colors
  static const Color primaryColor = Color(0xFF2B5597);
  static const Color secondaryColor = Color(0xFF717375);
  static const Color accentColor = Color(0xFFF2395B);
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color backgroundColor = primaryColor; // Changed to primary color
  static const Color appBarBackgroundColor =
      primaryColor; // Changed to primary color
  static const Color cardColor = Color(0xFF13305d); // Changed to white
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color lightDividerColor = Color(0xFFE0E0E0);
  static const Color lightHintColor = Color(0xFF8A8A8A);
  static const Color transparent = Colors.transparent;
  static const Color gradient1 = Color(0xFF2a5394);
  static const Color gradient2 = Color(0xFF13305d);

  // Dark Theme Colors
  static const Color darkBackgroundColor =
      primaryColor; // Changed to primary color
  static const Color darkCardColor = whiteColor; // Changed to white
  static const Color darkSurfaceColor = Color(
    0xFF1E3A6F,
  ); // Lighter shade of primary for surfaces
  static const Color darkDividerColor = Color(
    0xFF4A6BA3,
  ); // Lighter shade of primary for dividers
  static const Color darkHintColor = Color(0xFFAAAAAA);

  // Gradient for cards
  static const LinearGradient cardGradient = LinearGradient(
    colors: [gradient1, gradient2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Font definition - single source of truth
  static TextStyle _createTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    required Color color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // Generate theme text theme based on brightness
  static TextTheme _createTextTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color textColor =
        whiteColor; // Text color is white for primary backgrounds
    final Color captionColor =
        isLight
            ? Color(0xFFB8C5D1)
            : Color(0xFFB8C5D1); // Light blue-gray for captions

    return TextTheme(
      headlineLarge: _createTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: _createTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineSmall: _createTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: _createTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: _createTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: _createTextStyle(fontSize: 16, color: textColor),
      bodyMedium: _createTextStyle(fontSize: 14, color: textColor),
      bodySmall: _createTextStyle(fontSize: 12, color: captionColor),
      labelLarge: _createTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor, // Primary color for labels on white buttons
      ),
    );
  }

  // Common theme properties that are shared between light and dark themes
  static ThemeData _createBaseTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color backgroundColor = primaryColor; // Primary color background
    final Color cardColor =
        gradient2; // Use gradient1 as base card color for theme compatibility
    final Color surfaceColor = isLight ? gradient1 : darkSurfaceColor;
    final Color dividerColor = isLight ? lightDividerColor : darkDividerColor;
    final Color textColor = whiteColor; // White text on primary backgrounds
    final Color cardTextColor = whiteColor; // White text on gradient cards
    final Color hintColor = isLight ? Color(0xFFB8C5D1) : darkHintColor;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: whiteColor,
        secondary: whiteColor, // White secondary for buttons
        onSecondary: primaryColor, // Primary text on white secondary
        error: errorColor,
        onError: whiteColor,
        surface: surfaceColor,
        onSurface: whiteColor, // White text on gradient surfaces
      ),
      textTheme: _createTextTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.light, // Light icons on primary background
        ),
        iconTheme: IconThemeData(color: whiteColor),
        titleTextStyle: _createTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteColor, // White buttons
          foregroundColor: primaryColor, // Primary color text
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: _createTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: whiteColor, // White background
          foregroundColor: primaryColor, // Primary color text
          side: const BorderSide(color: whiteColor, width: 1.5), // White border
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: _createTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: whiteColor, // White background
          foregroundColor: primaryColor, // Primary color text
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _createTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: whiteColor, // White FAB
        foregroundColor: primaryColor, // Primary color icon
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryColor, // Primary color input fields
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: whiteColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: whiteColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: whiteColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: _createTextStyle(fontSize: 16, color: whiteColor),
        hintStyle: _createTextStyle(fontSize: 16, color: Color(0xFFB8C5D1)),
        helperStyle: _createTextStyle(fontSize: 12, color: Color(0xFFB8C5D1)),
        counterStyle: _createTextStyle(fontSize: 12, color: Color(0xFFB8C5D1)),
        errorStyle: _createTextStyle(fontSize: 12, color: errorColor),
        prefixIconColor: whiteColor,
        suffixIconColor: whiteColor,
      ),
      cardTheme: CardThemeData(
        color:
            gradient1, // Base color for theme compatibility (actual gradient applied via decoration)
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: gradient1, // Gradient color for list tiles
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: whiteColor, // White text on gradient tiles
        iconColor: whiteColor, // White icons on gradient tiles
      ),
      dividerTheme: DividerThemeData(
        color: Color(0xFFB8C5D1), // Light divider color
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: whiteColor, // White snackbar
        contentTextStyle: _createTextStyle(fontSize: 14, color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: whiteColor, // White bottom navigation
        selectedItemColor: primaryColor, // Primary color for selected items
        unselectedItemColor: secondaryColor, // Secondary color for unselected
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: _createTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        unselectedLabelStyle: _createTextStyle(
          fontSize: 12,
          color: secondaryColor,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: whiteColor, // White labels on primary background
        unselectedLabelColor: Color(0xFFB8C5D1), // Light color for unselected
        indicatorColor: whiteColor, // White indicator
        labelStyle: _createTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: whiteColor,
        ),
        unselectedLabelStyle: _createTextStyle(
          fontSize: 14,
          color: Color(0xFFB8C5D1),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return whiteColor; // White checkbox when selected
          }
          return whiteColor;
        }),
        checkColor: WidgetStateProperty.all(
          primaryColor,
        ), // Primary color check mark
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return whiteColor; // White radio when selected
          }
          return whiteColor;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return whiteColor; // White thumb when selected
          }
          return whiteColor;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return whiteColor.withOpacity(0.5); // Semi-transparent white track
          }
          return whiteColor.withOpacity(0.3);
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: whiteColor, // White progress indicators
        circularTrackColor: whiteColor.withOpacity(0.3),
        linearTrackColor: whiteColor.withOpacity(0.3),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: gradient1, // Gradient color for chips
        disabledColor: gradient1.withOpacity(0.5),
        selectedColor: gradient2,
        secondarySelectedColor: gradient2.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        labelStyle: _createTextStyle(fontSize: 14, color: whiteColor),
        secondaryLabelStyle: _createTextStyle(fontSize: 14, color: whiteColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: gradient2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: gradient1, // Gradient color for bottom sheets
        modalBackgroundColor: gradient1,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: gradient1, // Gradient color for dialogs
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: gradient1, // Gradient color for time picker
        hourMinuteColor: gradient2.withOpacity(0.3),
        hourMinuteTextColor: whiteColor,
        dialHandColor: whiteColor,
        dialBackgroundColor: gradient2.withOpacity(0.2),
        entryModeIconColor: whiteColor,
      ),
    );
  }

  // Light Theme
  static final ThemeData lightTheme = _createBaseTheme(Brightness.light);

  // Dark Theme
  static final ThemeData darkTheme = _createBaseTheme(Brightness.dark);

  // Method to get status bar color based on the app's theme
  static SystemUiOverlayStyle getStatusBarStyle({required bool isLightTheme}) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // Light icons on primary background
      systemNavigationBarColor: primaryColor, // Primary color navigation bar
      systemNavigationBarIconBrightness: Brightness.light,
    );
  }

  // Reusable text styles using our centralized font creation method
  static TextStyle get headerStyle => _createTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: whiteColor, // White text for primary backgrounds
  );

  static TextStyle get subheaderStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: whiteColor,
  );

  static TextStyle get bodyStyle =>
      _createTextStyle(fontSize: 16, color: whiteColor);

  static TextStyle get captionStyle =>
      _createTextStyle(fontSize: 12, color: Color(0xFFB8C5D1));

  // Text styles for gradient backgrounds (cards, etc.)
  static TextStyle get cardHeaderStyle => _createTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: whiteColor, // White text on gradient cards
  );

  static TextStyle get cardSubheaderStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: whiteColor,
  );

  static TextStyle get cardBodyStyle =>
      _createTextStyle(fontSize: 16, color: whiteColor);

  static TextStyle get cardCaptionStyle =>
      _createTextStyle(fontSize: 12, color: Color(0xFFB8C5D1));

  // Custom button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: whiteColor, // White buttons
    foregroundColor: primaryColor, // Primary color text
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: _createTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: primaryColor,
    ),
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    backgroundColor: whiteColor,
    foregroundColor: primaryColor,
    side: const BorderSide(color: whiteColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: _createTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: primaryColor,
    ),
  );

  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: whiteColor,
    foregroundColor: accentColor, // Accent color text on white button
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: _createTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: accentColor,
    ),
  );

  // Themed text styles that adapt based on current theme
  static TextStyle getThemedHeaderStyle(bool isLightTheme) => _createTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: whiteColor, // Always white for primary backgrounds
  );

  static TextStyle getThemedSubheaderStyle(bool isLightTheme) =>
      _createTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: whiteColor,
      );

  static TextStyle getThemedBodyStyle(bool isLightTheme) =>
      _createTextStyle(fontSize: 16, color: whiteColor);

  static TextStyle getThemedCaptionStyle(bool isLightTheme) =>
      _createTextStyle(fontSize: 12, color: Color(0xFFB8C5D1));

  // Additional helper methods for card content (gradient backgrounds)
  static TextStyle getCardThemedHeaderStyle(bool isLightTheme) =>
      _createTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: whiteColor, // White text on gradient cards
      );

  static TextStyle getCardThemedSubheaderStyle(bool isLightTheme) =>
      _createTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: whiteColor,
      );

  static TextStyle getCardThemedBodyStyle(bool isLightTheme) =>
      _createTextStyle(fontSize: 16, color: whiteColor);

  static TextStyle getCardThemedCaptionStyle(bool isLightTheme) =>
      _createTextStyle(fontSize: 12, color: Color(0xFFB8C5D1));

  // Helper method to create gradient decoration for cards
  static Decoration get cardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(12),
  );

  // Helper method to create gradient decoration with custom border radius
  static Decoration getCardDecoration({BorderRadius? borderRadius}) =>
      BoxDecoration(
        gradient: cardGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      );
}
