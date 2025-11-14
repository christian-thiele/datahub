import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;

import 'package:fixnum/fixnum.dart';
import 'package:uuid/uuid.dart';

import 'api_error.dart';

const Map<int, String> _statusCodes = {
  // Informative
  100: 'Continue',
  101: 'Switching Protocol',
  102: 'Processing',
  103: 'Early Hints',

  // Success
  200: 'OK',
  201: 'Created',
  202: 'Accepted',
  203: 'Non-Authorative Information',
  204: 'No Content',
  205: 'Reset Content',
  206: 'Partial Content',
  208: 'Already Reported',
  226: 'IM Used',

  // Redirect
  300: 'Multiple choice',
  301: 'Moved Permanently',
  302: 'Found',
  303: 'See Other',
  304: 'Not Modified',
  305: 'Use Proxy',
  307: 'Temporary Redirect',
  308: 'Permanent Redirect',

  // Client error
  400: 'Bad Request',
  401: 'Unauthorized',
  402: 'Payment Required',
  403: 'Forbidden',
  404: 'Not Found',
  405: 'Method Not Allowed',
  406: 'Not Acceptable',
  407: 'Proxy Authentication Required',
  408: 'Request Timeout',
  409: 'Conflict',
  410: 'Gone',
  411: 'Length Required',
  412: 'Precondition Failed',
  413: 'Payload Too Large',
  414: 'URI Too Long',
  415: 'Unsupported Media Type',
  416: 'Requested Range Not Satisfiable',
  417: 'Expectation Failed',
  421: 'Misdirected Request',
  426: 'Upgrade Required',
  428: 'Precondition Required',
  429: 'Too Many Requests',
  431: 'Request Header Fields Too Large',
  451: 'Unavailable For Legal Reasons',

  // Server Error
  500: 'Internal Server Error',
  501: 'Not Implemented',
  502: 'Bad Gateway',
  503: 'Service Unavailable',
  504: 'Gateway Timeout',
  505: 'HTTP Version Not Supported',
  506: 'Variant Also Negotiates',
  507: 'Insufficient Storage',
  508: 'Loop Detected',
  510: 'Not Extended',
  511: 'Network Authentication Required',
};

String getHttpStatus(int statusCode) =>
    _statusCodes[statusCode] ?? 'Unknown Status';

String uuid() => Uuid().v1().toString();

String addBase64Padding(String value) {
  final length = value.length;
  final pad = length % 4;
  if (pad != 0) {
    return value.padRight(length + 4 - pad, '=');
  }
  return value;
}

String stripBase64Padding(String value) {
  return value.replaceAll(RegExp(r'=+$'), '');
}

Iterable<int> randomBytes(int length) {
  final r = Random();
  return Iterable.generate(length, (i) => r.nextInt(255));
}

String randomHexId(int parts) {
  return randomBytes(
    parts,
  ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
}

Iterable<Iterable<T>> everyCombination<T>(Iterable<Iterable<T>> lists) sync* {
  if (lists.length == 1) {
    yield* lists.first.map((e) => [e]);
    return;
  }

  for (final element in lists.first) {
    yield* everyCombination(lists.skip(1)).map((e) => [element, ...e]);
  }
}

extension DateTimeExtension on DateTime {
  Int64 get nanosecondsSinceEpochInt64 => Int64(microsecondsSinceEpoch) * 1000;

  int get nanosecondsSinceEpoch => microsecondsSinceEpoch * 1000;

  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
}

DateTime earliest(DateTime a, DateTime b) {
  return a.isBefore(b) ? a : b;
}

DateTime latest(DateTime a, DateTime b) {
  return a.isBefore(b) ? b : a;
}

typedef Test<T> = bool Function(T e);

bool always(dynamic _) => true;

T pass<T>(T e) => e;

extension DurationJitterExtension on Duration {
  Duration jitter(Duration jitter) {
    final jitterFactor = math.Random().nextDouble();
    final jitterAmount = jitter * jitterFactor;
    return this + jitterAmount;
  }
}

extension StringExtension on String {
  Iterable<String> splitLineLength(int lineLength) sync* {
    var i = 0;
    while (i < length) {
      final part = substring(i, i + math.min(length - i, lineLength));
      final firstBreak = part.indexOf('\n');
      if (firstBreak > -1) {
        yield part.substring(0, firstBreak);
        i += firstBreak + 1;
      } else {
        i += part.length;
        yield part.trim();
      }
    }
  }
}

/// Decode unsigned BigInt value from base64 with or without padding.
BigInt base64UintDecode(String base64) {
  final bytes = base64Decode(addBase64Padding(base64));
  var result = BigInt.zero;
  for (var i = 0; i < bytes.length; i++) {
    result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
  }
  return result;
}

/// Encode unsigned BigInt value as base64url without padding.
String base64UintEncode(BigInt number) {
  final oneByte = BigInt.from(0xff);
  if (number.isNegative) {
    throw ApiError('Negative BigInt cannot be encoded to base64uint.');
  }

  var temp = number;
  final bytes = <int>[];
  while (temp > BigInt.zero) {
    bytes.insert(0, (temp & oneByte).toInt());
    temp >>= 8;
  }

  return stripBase64Padding(base64UrlEncode(bytes));
}
