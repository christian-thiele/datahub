import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';

class BearerAuth extends HttpAuth {
  final String prefix;
  final String token;

  BearerAuth(this.token, {this.prefix = 'Bearer '});

  static BearerAuth? fromAuthorizationHeader(String token,
      {String prefix = 'Basic '}) {
    if (token.length > prefix.length && token.startsWith(prefix)) {
      return BearerAuth(token.substring(prefix.length), prefix: prefix);
    } else {
      return null;
    }
  }

  static BearerAuth? fromRequest(ApiRequest request,
      {String prefix = 'Bearer '}) {
    final token = request.headers[HttpHeaders.authorization]?.firstOrNull;
    if (nullOrWhitespace(token)) {
      return null;
    }

    return BearerAuth.fromAuthorizationHeader(token!, prefix: prefix);
  }

  @override
  String get authorization => prefix + token;

  @override
  String toString() => authorization;
}
