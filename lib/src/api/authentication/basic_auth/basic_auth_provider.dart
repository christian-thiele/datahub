import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';

import 'basic_auth_session.dart';

class BasicAuthProvider extends AuthProvider {
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
      return BasicAuthSession(BasicAuth.fromRequest(request, prefix: prefix));
    }

    return null;
  }
}
