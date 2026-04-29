import 'package:web/web.dart' as html show document;

/// Returns the URI derived from the `<base href>` element in index.html.
/// Reads the raw `href` attribute (e.g. `/app/`) and resolves it against
/// [Uri.base] so the origin is preserved.
Uri getBaseHref() {
  final href =
      html.document.querySelector('base')?.getAttribute('href') ?? '/';
  return Uri.base.resolve(href);
}
