import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';

class BearerAuth extends HttpAuth {
  final String prefix;
  final String token;

  BearerAuth(this.token, {this.prefix = 'Bearer '});

  factory BearerAuth.fromAuthorizationHeader(String token,
      {String prefix = 'Basic '}) {
    if (token.length > prefix.length) {
      return BearerAuth(token.substring(prefix.length));
    } else {
      throw ApiRequestException.unauthorized('Missing token.');
    }
  }

  factory BearerAuth.fromRequest(ApiRequest request,
      {String prefix = 'Basic '}) {
    final token = request.headers[HttpHeaders.authorization]?.firstOrNull;
    if (nullOrWhitespace(token)) {
      throw ApiRequestException.unauthorized();
    }

    return BearerAuth.fromAuthorizationHeader(token!, prefix: prefix);
  }

  @override
  String get authorization => prefix + token;

  @override
  String toString() => authorization;
}
