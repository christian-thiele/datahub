import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';

import 'basic_auth_session.dart';

abstract class BasicAuthProvider extends AuthProvider {
  final String prefix;

  BasicAuthProvider(
    super.internal, {
    this.prefix = 'Basic ',
    super.requireAuthorization = true,
  });

  @override
  Future<Session?> authorizeRequest(ApiRequest request) async {
    final auth = BasicAuth.fromRequest(request, prefix: prefix);
    if (auth != null) {
      return await getSession(auth);
    } else {
      return null;
    }
  }

  Future<BasicAuthSession> getSession(BasicAuth auth);
}
