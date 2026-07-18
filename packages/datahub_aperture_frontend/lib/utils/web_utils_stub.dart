/// Returns the URI derived from the `<base href>` element in index.html.
/// On non-web platforms, falls back to [Uri.base].
Uri getBaseHref() => Uri.base;

void notifyBootstrapDone() {}
