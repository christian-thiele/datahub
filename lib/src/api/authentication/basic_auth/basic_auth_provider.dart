import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';

import 'basic_auth_session.dart';

abstract class BasicAuthProvider extends AuthProvider {
  final String prefix;

  BasicAuthProvider(
    super.internal, {
    this.prefix = 'Bearer ',
    super.requireAuthentication = true,
  });

  @override
  Future<Session?> authenticateRequest(ApiRequest request) async {
    final token = request.headers[HttpHeaders.authorization]?.firstOrNull;
    if (token != null) {
      final auth = BasicAuth.fromRequest(request, prefix: prefix);
      return getSession(auth);
    }

    return null;
  }

  Future<BasicAuthSession> getSession(BasicAuth auth);
}
