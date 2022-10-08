import 'package:datahub/src/api/authentication/session.dart';
import 'package:rxdart/rxdart.dart';

import 'jwt.dart';

class JWTSession extends Session {
  final JWT token;

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
}
