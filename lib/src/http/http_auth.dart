import 'dart:convert';

import 'package:datahub/api.dart';

abstract class HttpAuth {
  String get authorization;
}

class BasicAuth extends HttpAuth {
  final String prefix;

  final String username;
  final String password;

  BasicAuth(this.username, this.password, {this.prefix = 'Basic '});

  factory BasicAuth.fromToken(String token, {String prefix = 'Basic '}) {
    final basicToken = token.substring(prefix.length);
    final decodedToken = utf8.decode(base64Decode(basicToken));
    final parts = decodedToken.split(':');
    if (parts.length < 2) {
      throw ApiRequestException.unauthorized();
    }

    return BasicAuth(parts.first, parts.skip(1).join(':'), prefix: prefix);
  }

  @override
  String get authorization => toString();

  @override
  String toString() {
    return prefix + base64Encode(utf8.encode('$username:$password'));
  }
}

class BearerToken extends HttpAuth {
  final String prefix;
  final String token;

  BearerToken(this.token, {this.prefix = 'Bearer '});

  @override
  String get authorization => toString();

  @override
  String toString() {
    return prefix + token;
  }
}
