import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';

import 'bearer_auth.dart';
import 'http_headers.dart';

class BasicAuth implements BearerAuth {
  @override
  final String prefix;

  final String username;
  final String password;

  BasicAuth(this.username, this.password, {this.prefix = 'Basic '});

  static BasicAuth? fromAuthorizationHeader(String token,
      {String prefix = 'Basic '}) {
    if (token.length > prefix.length && token.startsWith(prefix)) {
      final basicToken = token.substring(prefix.length);
      final decodedToken = utf8.decode(base64Decode(basicToken));
      final parts = decodedToken.split(':');
      if (parts.length < 2) {
        return null;
      }

      return BasicAuth(parts.first, parts.skip(1).join(':'), prefix: prefix);
    } else {
      return null;
    }
  }

  static BasicAuth? fromRequest(ApiRequest request,
      {String prefix = 'Basic '}) {
    final token = request.headers[HttpHeaders.authorization]?.firstOrNull;
    if (nullOrWhitespace(token)) {
      return null;
    }

    return BasicAuth.fromAuthorizationHeader(token!, prefix: prefix);
  }

  @override
  String get token => base64Encode(utf8.encode('$username:$password'));

  @override
  String get authorization => prefix + token;
}
