import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/http.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import '../telemetry/redaction.dart';

/// Logs the requests and responses passing through a [HttpRequestHandler] at
/// trace level.
///
/// Each exchange is logged as two records, identified by `event.name`: one
/// when the request arrives (`http.server.request.received`) and one once
/// sending the response body has ended (`http.server.response.sent`,
/// `http.server.response.aborted` if the client stopped receiving it or
/// `http.server.response.failed` if the body stream failed). The message is a
/// short summary, details are attached as labels named after the
/// OpenTelemetry semantic conventions (logfmt):
///
/// ```text
/// severity="TRACE" msg="Request received: POST /orders?page=1"
///   event.name="http.server.request.received" http.request.method="POST"
///   url.path="/orders" url.query="page=1"
///   http.request.header.content-type="application/json"
///   http.request.header.authorization="Bearer REDACTED" span="…" trace="…"
/// severity="TRACE" msg="Response sent: 201 for POST /orders?page=1 in 4.2 ms"
///   event.name="http.server.response.sent" http.request.method="POST"
///   url.path="/orders" url.query="page=1" http.response.status_code="201"
///   http.server.request.duration="0.0042" http.request.body.size="14"
///   http.request.body.content="{\"item\":\"abc\"}" http.response.body.size="8"
///   http.response.body.content="{\"id\":1}"
///   http.response.header.content-type="application/json" span="…" trace="…"
/// ```
///
/// Both records are logged within the span of the request, so they carry its
/// trace context. The response record repeats the request method and target,
/// so it can be read on its own. Its duration (in seconds, like the
/// `http.server.request.duration` metric) includes sending the body.
///
/// Bodies are captured while they are streamed, so the handler consumes them
/// as usual and at most [bodyLimit] bytes of each body are held for logging.
/// Longer bodies are truncated (`*.body.truncated`), binary bodies are only
/// logged with their size.
///
/// Credentials in headers and query parameters are replaced by `REDACTED`,
/// bodies are logged as they are.
class RequestLogger {
  /// Maximum number of bytes logged per body.
  ///
  /// If 0, no body content is logged, only body sizes.
  final int bodyLimit;

  /// Lowercase names of the headers that are redacted.
  final Set<String> _redactedHeaders;

  /// Creates a request logger that redacts [redactedHeaders] (matched
  /// case-insensitively) in addition to common credential headers.
  RequestLogger({
    required this.bodyLimit,
    Iterable<String> redactedHeaders = const [],
  }) : _redactedHeaders = {
         ...Redaction.sensitiveHeaders,
         ...redactedHeaders.map((e) => e.toLowerCase()),
       };

  Future<HttpResponse> handle(
    HttpRequest request,
    HttpRequestHandler handler,
  ) async {
    final watch = Stopwatch()..start();
    // the response body is sent from the zone of the HTTP server, the
    // response record is logged from the request zone (and span) instead
    final zone = Zone.current;

    final method = request.method.name.toUpperCase();
    final path = _escape(request.path);
    final query = _query(request.requestUri);
    final target = query == null ? path : '$path?$query';
    final requestAttributes = {
      'http.request.method': method,
      'url.path': path,
      'url.query': ?query,
    };

    log.trace(
      'Request received: $method $target',
      labels: {
        'event.name': 'http.server.request.received',
        ...requestAttributes,
        ..._headers('http.request.header', request.headers),
      },
    );

    final requestBody = _BodyCapture(bodyLimit);
    final response = await handler(
      HttpRequest(
        request.method,
        request.requestUri,
        request.headers,
        requestBody.observe(request.bodyData),
      ),
    );

    void logResponse(_BodyCapture? responseBody) {
      final elapsed = watch.elapsedMicroseconds;
      final (outcome, errorType) = switch (responseBody) {
        _BodyCapture(state: _BodyState.aborted) => ('aborted', 'aborted'),
        _BodyCapture(state: _BodyState.failed, :final error) => (
          'failed',
          error.runtimeType.toString(),
        ),
        _ => ('sent', null),
      };

      log.trace(
        'Response $outcome: ${response.statusCode} for $method $target '
        '${errorType == null ? 'in' : 'after'} '
        '${(elapsed / 1000).toStringAsFixed(1)} ms',
        error: responseBody?.error,
        labels: {
          'event.name': 'http.server.response.$outcome',
          ...requestAttributes,
          'http.response.status_code': response.statusCode.toString(),
          'http.server.request.duration': (elapsed / 1000000).toString(),
          ...requestBody.attributes('http.request.body', request.headers),
          ...?responseBody?.attributes('http.response.body', response.headers),
          ..._headers('http.response.header', response.headers),
          'error.type': ?errorType,
        },
      );
    }

    // the socket is handed over without sending a body
    if (response is UpgradeHttpResponse) {
      logResponse(null);
      return response;
    }

    // observed even if no content is logged, since its end triggers the
    // response record
    final responseBody = _BodyCapture(bodyLimit);
    return HttpResponse(
      response.requestUrl,
      response.statusCode,
      response.headers,
      responseBody.observe(
        response.bodyData,
        onEnd: () => zone.run(() => logResponse(responseBody)),
      ),
    );
  }

  /// Query of [uri] with credentials redacted, or null if there is none.
  static String? _query(Uri uri) =>
      uri.hasQuery ? _escape(Redaction.redactQuery(uri.query)) : null;

  /// Header labels as defined by the semantic conventions, with multiple
  /// values combined into a comma-separated list.
  Map<String, String> _headers(
    String prefix,
    Map<String, List<String>> headers,
  ) {
    final labels = <String, String>{};
    for (final MapEntry(:key, :value) in headers.entries) {
      final name = key.toLowerCase();
      final values = _redactedHeaders.contains(name)
          ? value.map(Redaction.redactHeaderValue)
          : value.map(_escape);
      labels.update(
        '$prefix.$name',
        (existing) => [existing, ...values].join(', '),
        ifAbsent: () => values.join(', '),
      );
    }
    return labels;
  }
}

enum _BodyState { pending, complete, aborted, failed }

/// Counts the bytes of a body and keeps the first [limit] bytes for logging.
class _BodyCapture {
  final int limit;
  final _bytes = BytesBuilder();
  int _length = 0;
  _BodyState state = _BodyState.pending;
  Object? error;

  _BodyCapture(this.limit);

  /// Returns [source], capturing its data while it is consumed.
  ///
  /// [onEnd] is called once, when [source] is done, fails or the subscriber
  /// cancels.
  Stream<List<int>> observe(
    Stream<List<int>> source, {
    void Function()? onEnd,
  }) {
    void end(_BodyState endState, [Object? endError]) {
      if (state == _BodyState.pending) {
        state = endState;
        error = endError;
        onEnd?.call();
      }
    }

    late final StreamSubscription<List<int>> subscription;
    final controller = StreamController<List<int>>(sync: true);
    controller
      ..onListen = () {
        subscription = source.listen(
          (chunk) {
            _capture(chunk);
            controller.add(chunk);
          },
          onError: (Object e, StackTrace stack) {
            end(_BodyState.failed, e);
            controller.addError(e, stack);
          },
          onDone: () {
            end(_BodyState.complete);
            controller.close();
          },
        );
      }
      ..onPause = (() => subscription.pause())
      ..onResume = (() => subscription.resume())
      ..onCancel = () {
        end(_BodyState.aborted);
        return subscription.cancel();
      };

    return controller.stream;
  }

  void _capture(List<int> chunk) {
    _length += chunk.length;
    final remaining = limit - _bytes.length;
    if (remaining > 0) {
      _bytes.add(
        chunk.length <= remaining ? chunk : chunk.sublist(0, remaining),
      );
    }
  }

  /// Labels describing the body: `size` (bytes consumed), `content` (text
  /// bodies only) and `truncated`.
  ///
  /// Empty if the body was not consumed, since its size is unknown.
  Map<String, String> attributes(
    String prefix,
    Map<String, List<String>> headers,
  ) {
    if (state == _BodyState.pending && _length == 0) {
      return const {};
    }

    final bytes = _bytes.toBytes();
    final truncated = _length > bytes.length;
    final content = bytes.isNotEmpty
        ? _decode(
            bytes,
            _header(headers, HttpHeaders.contentType),
            truncated: truncated,
          )
        : null;

    return {
      '$prefix.size': _length.toString(),
      '$prefix.content': ?content,
      if (content != null && truncated) '$prefix.truncated': 'true',
    };
  }

  /// Decodes [bytes] as UTF-8, or returns null if they are not text.
  static String? _decode(
    Uint8List bytes,
    String? contentType, {
    required bool truncated,
  }) {
    final mimeType = contentType?.split(';').first.trim().toLowerCase();
    if (mimeType != null && !_isText(mimeType)) {
      return null;
    }

    var text = utf8.decode(bytes, allowMalformed: true);
    // truncation may split a multi-byte character
    if (truncated && text.endsWith('�')) {
      text = text.substring(0, text.length - 1);
    }

    // sniff bodies without content type
    if (mimeType == null && (text.contains('�') || text.contains('\u0000'))) {
      return null;
    }

    return _escape(text, keepLineFeeds: true);
  }

  static bool _isText(String mimeType) =>
      mimeType.startsWith('text/') ||
      mimeType.endsWith('/json') ||
      mimeType.endsWith('+json') ||
      mimeType.endsWith('/xml') ||
      mimeType.endsWith('+xml') ||
      mimeType.endsWith('/yaml') ||
      mimeType.endsWith('/x-yaml') ||
      mimeType == Mime.formData ||
      mimeType == 'application/javascript' ||
      mimeType == 'application/graphql';

  static String? _header(Map<String, List<String>> headers, String name) =>
      headers.entries
          .where((e) => e.key.toLowerCase() == name)
          .expand((e) => e.value)
          .firstOrNull;
}

/// Escapes control characters except tabs (and line feeds if
/// [keepLineFeeds] is set), so logged data cannot forge log lines or inject
/// terminal escape sequences.
String _escape(String value, {bool keepLineFeeds = false}) =>
    value.replaceAllMapped(
      keepLineFeeds
          ? RegExp(r'[\x00-\x08\x0B-\x1F\x7F]')
          : RegExp(r'[\x00-\x08\x0A-\x1F\x7F]'),
      (m) => switch (m[0]!) {
        '\n' => r'\n',
        '\r' => r'\r',
        final c => '\\u${c.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}',
      },
    );
