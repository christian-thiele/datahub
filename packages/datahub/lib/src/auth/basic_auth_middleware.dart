import 'package:datahub/api.dart';
import 'package:datahub/config.dart';
import 'package:datahub/http.dart';
import 'package:datahub/scaffold.dart';

import 'authentication_middleware.dart';

abstract interface class BasicAuthProvider() {
  Future<Session> authenticateBasic(BasicAuth auth);
}

class const BasicAuthMiddleware({
  super.matcher,
  final Find<BasicAuthProvider> provider = const Find<BasicAuthProvider>(),
  final Config<String> prefix = const Config(
    'basicAuth.prefix',
    defaultValue: 'Basic ',
  ),
  required super.routes,
  super.catchRequests = false,
  super.requireSession = true,
}) extends AuthenticationMiddleware {
  @override
  Future<Session?> authenticate(ApiRequest request) async {
    final auth = BasicAuth.fromRequest(request.headers, prefix: prefix.read());
    if (auth != null) {
      return await provider.find().authenticateBasic(auth);
    } else {
      return null;
    }
  }
}
