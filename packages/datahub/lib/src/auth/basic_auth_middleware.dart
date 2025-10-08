import 'package:datahub/api.dart';
import 'package:datahub/config.dart';
import 'package:datahub/http.dart';
import 'package:datahub/scaffold.dart';

import 'authentication_middleware.dart';

abstract interface class BasicAuthProvider {
  Future<Session> authenticateBasic(BasicAuth auth);
}

class BasicAuthMiddleware extends AuthenticationMiddleware {
  final Find<BasicAuthProvider> provider;
  final Config<String> prefix;

  const BasicAuthMiddleware({
    super.matcher,
    this.provider = const Find<BasicAuthProvider>(),
    this.prefix = const Config('basicAuth.prefix', defaultValue: 'Basic '),
    required super.routes,
    super.catchRequests = false,
    super.requireSession = true,
  });

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
