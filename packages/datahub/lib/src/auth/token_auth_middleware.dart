import 'package:datahub/api.dart';
import 'package:datahub/config.dart';
import 'package:datahub/http.dart';
import 'package:datahub/scaffold.dart';

import 'authentication_middleware.dart';

abstract interface class TokenAuthProvider() {
  Future<Session> authenticate(TokenAuth auth);
}

class const TokenAuthMiddleware({
  super.matcher,
  required final Find<TokenAuthProvider> provider,
  final Config<String> prefix = const Config.value(''),
  required super.routes,
  super.catchRequests = false,
  super.requireSession = true,
}) extends AuthenticationMiddleware {
  @override
  Future<Session?> authenticate(ApiRequest request) async {
    final auth = TokenAuth.fromRequest(request.headers, prefix: prefix.read());
    if (auth != null) {
      return await provider.find().authenticate(auth);
    } else {
      return null;
    }
  }
}
