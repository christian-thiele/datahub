import 'package:boost/boost.dart';
import 'package:uuid/uuid.dart';

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
  511: 'Network Authentication Required'
};

String getHttpStatus(int statusCode) =>
    _statusCodes[statusCode] ?? 'Unknown Status';

String buildQueryString(Map<String, String?> query) {
  if (query.isEmpty) {
    return '';
  }

  String encodeEntry(MapEntry<String, String?> e) {
    final key = Uri.encodeQueryComponent(e.key);
    if (!nullOrEmpty(e.value)) {
      return '$key=${Uri.encodeQueryComponent(e.value!)}';
    } else {
      return key;
    }
  }

  return '?${query.entries.map(encodeEntry).join('&')}';
}

String uuid() => Uuid().v1().toString();

extension MapEquality<K, V> on Map<K, V> {
  bool entriesEqual(Map<K, V> other) {
    if (other.length != length) {
      return false;
    }

    for (final entry in entries) {
      if (other.containsKey(entry.key)) {
        return false;
      }
      if (entry.value != other[entry.key]) {
        return false;
      }
    }

    return true;
  }
}

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
