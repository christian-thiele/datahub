import 'package:boost/boost.dart';

import 'package:datahub/api.dart';
import 'package:datahub/http.dart';

import 'bearer_auth_session.dart';

abstract class BearerTokenAuthProvider extends AuthProvider {
  final String prefix;

  BearerTokenAuthProvider(
    super.internal, {
    this.prefix = 'Bearer ',
    super.requireAuthorization = true,
  });

  @override
  Future<Session?> authorizeRequest(ApiRequest request) async {
    final token = request.headers[HttpHeaders.authorization]?.firstOrNull;
    if (token != null) {
      final auth = BearerAuth.fromAuthorizationHeader(token, prefix: prefix);
      return getSession(auth);
    }

    return null;
  }

  Future<BearerAuthSession> getSession(BearerAuth auth);
}
