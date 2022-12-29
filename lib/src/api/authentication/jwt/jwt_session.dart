import 'package:rxdart/rxdart.dart';

import 'package:datahub/api.dart';

class JWTSession extends Session {
  final JWT token;

  String get subject =>
      token.sub ??
      (throw ApiRequestException.unauthorized('Invalid authorization.'));

  JWTSession(this.token);

  @override
  DateTime get timestamp => token.iat ?? DateTime.now();

  @override
  Stream<void> get expiration {
    if (token.exp != null) {
      return Rx.timer(null, token.exp!.difference(DateTime.now()));
    } else {
      return Rx.never();
    }
  }

  /// Accesses jwt payload values.
  dynamic operator [](String key) => token.payload[key];
}
