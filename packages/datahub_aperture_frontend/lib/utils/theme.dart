import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApertureThemeData {
  static ThemeData defaultTheme = buildWithSeedColor(Color(0xff295bf0));

  static ThemeData buildWithSeedColor(Color seedColor) =>
      buildWithColorScheme(_buildColorScheme(seedColor));

  static ColorScheme _buildColorScheme(Color seedColor) => ColorScheme.fromSeed(
    seedColor: seedColor,
    primary: seedColor,
    shadow: Color(0xA0000000),
    onSurface: Color(0xff404654),
  );

  static ThemeData buildWithColorScheme(ColorScheme colors) => ThemeData(
    colorScheme: colors,
    visualDensity: VisualDensity.compact,
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        labelMedium: TextStyle(color: Colors.black54),
        labelSmall: TextStyle(color: Colors.black54),
        bodySmall: TextStyle(fontSize: 8),
        bodyMedium: TextStyle(fontSize: 12),
        bodyLarge: TextStyle(fontSize: 14),
      ),
    ),
    appBarTheme: AppBarTheme(leadingWidth: 128),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsetsGeometry.zero,
      color: colors.surfaceBright,
    ),
    dialogTheme: DialogThemeData(
      barrierColor: Color(0xA0C0C0C0),
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      )
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      },
    ),
    iconTheme: IconThemeData(size: 18),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconSize: WidgetStatePropertyAll(18),
        visualDensity: VisualDensity.compact,
      ),
    ),
  );
}
