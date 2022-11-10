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
    final auth = BearerAuth.fromRequest(request, prefix: prefix);
    if (auth != null) {
      return await getSession(auth);
    } else {
      return null;
    }
  }

  Future<BearerAuthSession> getSession(BearerAuth auth);
}
