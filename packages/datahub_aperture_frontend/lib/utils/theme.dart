import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colours that have no slot in [ColorScheme].
///
/// Neutrals follow the ReactiveData palette (slate, hue 221°), accents are
/// derived from the configurable seed colour.
@immutable
class ApertureColors extends ThemeExtension<ApertureColors> {
  /// Page background behind cards and panels.
  final Color canvas;

  /// Hairline borders of cards, panels and dividers.
  final Color border;

  /// Borders of controls like inputs and outlined buttons.
  final Color borderStrong;

  /// Headings and emphasized text.
  final Color textStrong;

  /// Secondary text like labels and captions.
  final Color textMuted;

  /// Text in the primary colour, readable on [canvas].
  final Color link;

  /// Tinted background of selected or highlighted elements.
  final Color accentSubtle;

  final Color success;
  final Color successSubtle;
  final Color warning;
  final Color warningSubtle;
  final Color danger;
  final Color dangerSubtle;

  final Gradient brandGradient;

  const ApertureColors({
    required this.canvas,
    required this.border,
    required this.borderStrong,
    required this.textStrong,
    required this.textMuted,
    required this.link,
    required this.accentSubtle,
    required this.success,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.danger,
    required this.dangerSubtle,
    required this.brandGradient,
  });

  /// The brand colours of the ambient theme, or ones derived from its primary
  /// colour if it is not an Aperture theme.
  static ApertureColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<ApertureColors>() ??
        ApertureThemeData.buildWithSeedColor(
          theme.colorScheme.primary,
          brightness: theme.brightness,
        ).extension<ApertureColors>()!;
  }

  @override
  ApertureColors copyWith() => this;

  @override
  ApertureColors lerp(ApertureColors? other, double t) {
    if (other == null) {
      return this;
    }

    return ApertureColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      link: Color.lerp(link, other.link, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSubtle: Color.lerp(successSubtle, other.successSubtle, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSubtle: Color.lerp(warningSubtle, other.warningSubtle, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSubtle: Color.lerp(dangerSubtle, other.dangerSubtle, t)!,
      brandGradient: Gradient.lerp(brandGradient, other.brandGradient, t)!,
    );
  }
}

class ApertureThemeData {
  static const defaultSeedColor = Color(0xff295bf0);

  static const radiusSmall = 6.0;
  static const radius = 8.0;
  static const radiusLarge = 12.0;

  static ThemeData defaultTheme = buildWithSeedColor(defaultSeedColor);

  static ThemeData buildWithSeedColor(
    Color seedColor, {
    Brightness brightness = Brightness.light,
  }) => switch (brightness) {
    Brightness.light => _build(_Palette.light(seedColor)),
    Brightness.dark => _build(_Palette.dark(seedColor)),
  };

  static ThemeData _build(_Palette p) {
    final colors = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: Colors.white,
      primaryContainer: p.accentSubtle,
      onPrimaryContainer: p.link,
      secondary: p.textMuted,
      onSecondary: p.surface,
      secondaryContainer: p.surfaceHigh,
      onSecondaryContainer: p.text,
      tertiary: p.warning,
      onTertiary: Colors.white,
      tertiaryContainer: p.warningSubtle,
      onTertiaryContainer: p.warning,
      error: p.danger,
      onError: Colors.white,
      errorContainer: p.dangerSubtle,
      onErrorContainer: p.danger,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.textMuted,
      surfaceDim: p.canvas,
      surfaceBright: p.surface,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surfaceLow,
      surfaceContainer: p.surfaceLow,
      surfaceContainerHigh: p.surfaceHigh,
      surfaceContainerHighest: p.surfaceHigh,
      outline: p.borderStrong,
      outlineVariant: p.border,
      shadow: p.shadow,
      scrim: p.scrim,
      inverseSurface: p.inverse,
      onInverseSurface: p.onInverse,
      inversePrimary: p.link,
      surfaceTint: Colors.transparent,
    );

    final extension = ApertureColors(
      canvas: p.canvas,
      border: p.border,
      borderStrong: p.borderStrong,
      textStrong: p.textStrong,
      textMuted: p.textMuted,
      link: p.link,
      accentSubtle: p.accentSubtle,
      success: p.success,
      successSubtle: p.successSubtle,
      warning: p.warning,
      warningSubtle: p.warningSubtle,
      danger: p.danger,
      dangerSubtle: p.dangerSubtle,
      brandGradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [p.primary, const Color(0xff25e4e1), const Color(0xff88d9c6)],
        stops: const [0, 0.8, 1],
      ),
    );

    final textTheme = _textTheme(p);

    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 16);
    const buttonMinimumSize = Size(64, 36);
    final buttonText = textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    final menuStyle = MenuStyle(
      backgroundColor: WidgetStatePropertyAll(p.surface),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: WidgetStatePropertyAll(p.shadow),
      elevation: const WidgetStatePropertyAll(8),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge - 2),
          side: BorderSide(color: p.border),
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colors,
      extensions: [extension],
      visualDensity: VisualDensity.compact,
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.surface,
      dividerColor: p.border,
      hoverColor: p.hover,
      focusColor: p.accentSubtle,
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,
      iconTheme: IconThemeData(size: 18, color: p.textMuted),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primary.withAlpha(60),
        selectionHandleColor: p.primary,
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: p.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: p.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.standard,
          shape: controlShape,
          padding: buttonPadding,
          minimumSize: buttonMinimumSize,
          textStyle: buttonText,
          disabledBackgroundColor: p.surfaceHigh,
          disabledForegroundColor: p.textFaint,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          visualDensity: VisualDensity.standard,
          shape: controlShape,
          padding: buttonPadding,
          minimumSize: buttonMinimumSize,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          shape: WidgetStatePropertyAll(controlShape),
          padding: const WidgetStatePropertyAll(buttonPadding),
          minimumSize: const WidgetStatePropertyAll(buttonMinimumSize),
          textStyle: WidgetStatePropertyAll(buttonText),
          backgroundColor: WidgetStatePropertyAll(p.surface),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? p.textFaint
                : p.textStrong,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? p.textFaint
                : p.textMuted,
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? p.border
                  : p.borderStrong,
            ),
          ),
          overlayColor: WidgetStatePropertyAll(p.hover),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.standard,
          shape: controlShape,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: buttonMinimumSize,
          textStyle: buttonText,
          foregroundColor: p.link,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          iconSize: 18,
          visualDensity: VisualDensity.standard,
          minimumSize: const Size.square(36),
          padding: const EdgeInsets.all(8),
          foregroundColor: p.textMuted,
          disabledForegroundColor: p.textFaint.withAlpha(140),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: p.inputFill,
        hoverColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        // A single state dependent border, so that it does not leak into
        // decorations that disable their border, like collapsed ones.
        border: WidgetStateInputBorder.resolveWith(
          (states) => switch (states) {
            _ when states.contains(WidgetState.disabled) => inputBorder(
              p.border,
            ),
            _ when states.contains(WidgetState.error) => inputBorder(
              p.danger,
              states.contains(WidgetState.focused) ? 1.5 : 1,
            ),
            _ when states.contains(WidgetState.focused) => inputBorder(
              p.primary,
              1.5,
            ),
            _ => inputBorder(p.borderStrong),
          },
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: p.textMuted),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (states) => textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w500,
            color: switch (states) {
              _ when states.contains(WidgetState.error) => p.danger,
              _ when states.contains(WidgetState.focused) => p.link,
              _ => p.textMuted,
            },
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.textFaint),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: p.danger),
        prefixIconColor: p.textMuted,
        suffixIconColor: p.textMuted,
        iconColor: p.textMuted,
      ),
      searchBarTheme: SearchBarThemeData(
        shape: WidgetStatePropertyAll(controlShape),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        constraints: const BoxConstraints(
          minHeight: 36,
          maxHeight: double.infinity,
        ),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BorderSide.none
              : BorderSide(color: p.borderStrong, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.accentSubtle,
        side: BorderSide(color: p.borderStrong),
        shape: controlShape,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: p.text,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: p.textMuted, size: 16),
        deleteIconColor: p.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        elevation: 0,
        pressElevation: 0,
      ),
      menuTheme: MenuThemeData(style: menuStyle),
      dropdownMenuTheme: DropdownMenuThemeData(menuStyle: menuStyle),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSmall),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(160, 36)),
          textStyle: WidgetStatePropertyAll(textTheme.bodyMedium),
          foregroundColor: WidgetStatePropertyAll(p.text),
          iconColor: WidgetStatePropertyAll(p.textMuted),
          iconSize: const WidgetStatePropertyAll(18),
          overlayColor: WidgetStatePropertyAll(p.hover),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: p.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge - 2),
          side: BorderSide(color: p.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        barrierColor: p.scrim,
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shadowColor: p.shadow,
        titleTextStyle: textTheme.titleLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.border),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.inverse,
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: p.onInverse),
        actionTextColor: p.link,
        width: 400,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius + 2),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        textStyle: textTheme.labelMedium?.copyWith(color: p.onInverse),
        decoration: BoxDecoration(
          color: p.inverse,
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.accentSubtle,
        circularTrackColor: Colors.transparent,
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
        thumbColor: WidgetStatePropertyAll(p.borderStrong),
      ),
      listTileTheme: ListTileThemeData(
        shape: controlShape,
        iconColor: p.textMuted,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(_Palette p) => GoogleFonts.poppinsTextTheme(
    TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w800, color: p.textStrong),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w800,
        color: p.textStrong,
      ),
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: p.textStrong,
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: p.textStrong,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: p.textStrong,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: p.textStrong,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: p.textStrong,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: p.textStrong,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: p.textStrong,
      ),
      bodyLarge: TextStyle(fontSize: 14, color: p.text),
      bodyMedium: TextStyle(fontSize: 13, color: p.text),
      bodySmall: TextStyle(fontSize: 12, color: p.textMuted),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: p.text,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: p.textMuted,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: p.textMuted,
      ),
    ),
  );
}

/// Raw colour values for one brightness.
class _Palette {
  final Brightness brightness;
  final Color primary;
  final Color link;
  final Color accentSubtle;
  final Color canvas;
  final Color surface;
  final Color surfaceLow;
  final Color surfaceHigh;
  final Color inputFill;
  final Color hover;
  final Color border;
  final Color borderStrong;
  final Color textStrong;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color inverse;
  final Color onInverse;
  final Color shadow;
  final Color scrim;
  final Color success;
  final Color successSubtle;
  final Color warning;
  final Color warningSubtle;
  final Color danger;
  final Color dangerSubtle;

  const _Palette({
    required this.brightness,
    required this.primary,
    required this.link,
    required this.accentSubtle,
    required this.canvas,
    required this.surface,
    required this.surfaceLow,
    required this.surfaceHigh,
    required this.inputFill,
    required this.hover,
    required this.border,
    required this.borderStrong,
    required this.textStrong,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.inverse,
    required this.onInverse,
    required this.shadow,
    required this.scrim,
    required this.success,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.danger,
    required this.dangerSubtle,
  });

  factory _Palette.light(Color seed) {
    const surface = Color(0xffffffff);
    return _Palette(
      brightness: Brightness.light,
      primary: seed,
      link: Color.lerp(seed, const Color(0xff0a2b8f), 0.25)!,
      accentSubtle: Color.alphaBlend(seed.withAlpha(22), surface),
      canvas: const Color(0xfff5f6f8),
      surface: surface,
      surfaceLow: const Color(0xfff8f9fa),
      surfaceHigh: const Color(0xffeef0f3),
      inputFill: surface,
      hover: const Color(0x0a2e333d),
      border: const Color(0xffe4e7ec),
      borderStrong: const Color(0xffd3d7df),
      textStrong: const Color(0xff2e333d),
      text: const Color(0xff404654),
      textMuted: const Color(0xff6a7386),
      textFaint: const Color(0xff9aa1b0),
      inverse: const Color(0xff2e333d),
      onInverse: const Color(0xfff3f4f6),
      shadow: const Color(0x1f1b2230),
      scrim: const Color(0x662e333d),
      success: const Color(0xff1f8a5b),
      successSubtle: const Color(0xffe6f5ee),
      warning: const Color(0xffc26a12),
      warningSubtle: const Color(0xfffdf1e3),
      danger: const Color(0xffd23a3a),
      dangerSubtle: const Color(0xfffcebeb),
    );
  }

  factory _Palette.dark(Color seed) {
    const surface = Color(0xff16181d);
    return _Palette(
      brightness: Brightness.dark,
      primary: seed,
      link: Color.lerp(seed, const Color(0xffffffff), 0.45)!,
      accentSubtle: Color.alphaBlend(seed.withAlpha(46), surface),
      canvas: const Color(0xff0f1114),
      surface: surface,
      surfaceLow: const Color(0xff1a1d22),
      surfaceHigh: const Color(0xff22252c),
      inputFill: const Color(0xff121418),
      hover: const Color(0x0fffffff),
      border: const Color(0xff262a32),
      borderStrong: const Color(0xff353a45),
      textStrong: const Color(0xffebecf0),
      text: const Color(0xffc3c8d2),
      textMuted: const Color(0xff8d94a3),
      textFaint: const Color(0xff5d6473),
      inverse: const Color(0xffebecf0),
      onInverse: const Color(0xff2e333d),
      shadow: const Color(0x66000000),
      scrim: const Color(0x99000000),
      success: const Color(0xff3cc68a),
      successSubtle: const Color(0xff15291f),
      warning: const Color(0xfff0a04b),
      warningSubtle: const Color(0xff2e2214),
      danger: const Color(0xfff26d6d),
      dangerSubtle: const Color(0xff2f1a1c),
    );
  }
}
