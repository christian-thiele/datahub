import 'dart:convert';

import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Renders the page the browser shows when the identity provider redirects
/// back to the app after signing in.
///
/// The page mirrors the sign-in card and uses the provisioned logo and colors
/// of the [ApertureBootstrap.theme], in light and dark.
Future<String> renderAuthCallbackPage(
  ApertureBootstrap bootstrap, {
  required bool success,
}) async {
  final light = ApertureThemeData.buildWithSeedColor(
    Color(bootstrap.theme.color),
  );
  final dark = ApertureThemeData.buildWithSeedColor(
    Color(bootstrap.theme.color),
    brightness: Brightness.dark,
  );

  // Same as the sign-in card: the provisioned logo fits into 160x40 and is
  // tinted with the primary color, the fallback Aperture logo keeps its width.
  final hasLogo = bootstrap.theme.logo != null;
  final (logo, logoWidth) = switch (bootstrap.theme.logo) {
    final bytes? => (_imageUri(bytes), '160px'),
    null => (
      _dataUri('image/svg+xml', await _loadAsset('assets/aperture_logo.svg')),
      'auto',
    ),
  };

  Map<String, String> colorValues(ThemeData theme, String suffix) {
    final colors = theme.colorScheme;
    final extra = theme.extension<ApertureColors>()!;
    return {
      'logoColor$suffix': _cssColor(
        hasLogo ? colors.primary : extra.textStrong,
      ),
      'primary$suffix': _cssColor(colors.primary),
      'success$suffix': _cssColor(extra.success),
      'error$suffix': _cssColor(extra.danger),
      'canvas$suffix': _cssColor(extra.canvas),
      'surface$suffix': _cssColor(colors.surface),
      'border$suffix': _cssColor(extra.border),
      'onSurface$suffix': _cssColor(colors.onSurface),
      'textStrong$suffix': _cssColor(extra.textStrong),
      'textMuted$suffix': _cssColor(extra.textMuted),
      'successSubtle$suffix': _cssColor(extra.successSubtle),
      'errorSubtle$suffix': _cssColor(extra.dangerSubtle),
      'shadow$suffix': _cssColor(colors.shadow),
    };
  }

  const escape = HtmlEscape();
  final values = {
    'lang': Intl.getCurrentLocale().replaceAll('_', '-'),
    'title': escape.convert(bootstrap.title),
    'status': success ? 'success' : 'error',
    'headline': escape.convert(
      success
          ? S.current.authCallbackSuccessTitle
          : S.current.authCallbackErrorTitle,
    ),
    'message': escape.convert(
      success
          ? S.current.authCallbackSuccessMessage(bootstrap.title)
          : S.current.authCallbackErrorMessage(bootstrap.title),
    ),
    'font': _dataUri(
      'font/ttf',
      await _loadAsset('google_fonts/Poppins-Regular.ttf'),
    ),
    'logo': logo,
    'logoWidth': logoWidth,
    ...colorValues(light, ''),
    ...colorValues(dark, 'Dark'),
  };

  final template = await rootBundle.loadString('assets/auth_callback.html');
  return template.replaceAllMapped(
    RegExp(r'{{(\w+)}}'),
    (match) => values[match[1]]!,
  );
}

Future<Uint8List> _loadAsset(String key) async {
  final data = await rootBundle.load(key);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

// Browsers detect the format of raster images themselves,
// only SVG requires the correct mime type.
String _imageUri(Uint8List bytes) =>
    _dataUri(looksLikeSvg(bytes) ? 'image/svg+xml' : 'image/png', bytes);

String _dataUri(String mimeType, Uint8List bytes) =>
    'data:$mimeType;base64,${base64Encode(bytes)}';

String _cssColor(Color color) {
  String hex(double channel) =>
      (channel * 255).round().toRadixString(16).padLeft(2, '0');
  return '#${hex(color.r)}${hex(color.g)}${hex(color.b)}${hex(color.a)}';
}
