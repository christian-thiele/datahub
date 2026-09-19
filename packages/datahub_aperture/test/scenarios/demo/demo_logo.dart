import 'dart:convert';
import 'dart:typed_data';

/// Logo of the fictional company "Brightline Digital": a sun rising over a
/// line, next to a monoline wordmark drawn with strokes (no fonts needed).
///
/// Single colored, Aperture tints it with the primary theme color anyway.
final brightlineLogo = Uint8List.fromList(utf8.encode(_svg));

const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 248 48" fill="#0f766e" stroke="#0f766e">
<path d="M4 34H44M14 42H34M24 18V11M35.3 22.7l4.9-4.9M12.7 22.7l-4.9-4.9" fill="none" stroke-width="4" stroke-linecap="round"/>
<path d="M12 32a12 12 0 0 1 24 0Z"/>
<path d="M62 8V38M62 29a9 9 0 1 0 18 0a9 9 0 1 0-18 0M88 38V29a9 9 0 0 1 9-9M105 20V38M113 29a9 9 0 1 0 18 0a9 9 0 1 0-18 0M131 20V39a7 7 0 0 1-7 7H116M139 8V38M139 29a9 9 0 0 1 18 0V38M169 10V32a6 6 0 0 0 6 6H177M165 20H178M186 8V38M194 20V38M202 20V38M202 29a9 9 0 0 1 18 0V38M228 29H246a9 9 0 1 0-2.6 6.4" fill="none" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
<circle cx="105" cy="10" r="2.6"/>
<circle cx="194" cy="10" r="2.6"/>
</svg>
''';
