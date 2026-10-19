import 'package:boost/boost.dart';
import 'package:datahub/http.dart';

class TokenAuth(final String token, {final String prefix = 'Bearer '})
    extends HttpAuth {
  static TokenAuth? fromAuthorizationHeader(
    String token, {
    String prefix = 'Bearer ',
  }) {
    if (token.length > prefix.length && token.startsWith(prefix)) {
      return TokenAuth(token.substring(prefix.length), prefix: prefix);
    } else {
      return null;
    }
  }

  static TokenAuth? fromRequest(
    Map<String, List<String>> headers, {
    String prefix = 'Bearer ',
  }) {
    final token = headers[HttpHeaders.authorization]?.firstOrNull;
    if (nullOrWhitespace(token)) {
      return null;
    }

    return TokenAuth.fromAuthorizationHeader(token!, prefix: prefix);
  }

  @override
  String get authorization => prefix + token;

  @override
  String toString() => authorization;
}
