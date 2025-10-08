import 'package:datahub/api.dart';
import 'package:datahub/config.dart';
import 'package:datahub/http.dart';
import 'package:datahub/scaffold.dart';

import 'authentication_middleware.dart';

abstract interface class TokenAuthProvider {
  Future<Session> authenticate(TokenAuth auth);
}

abstract class TokenAuthMiddleware extends AuthenticationMiddleware {
  final Find<TokenAuthProvider> provider;
  final Config<String> prefix;

  const TokenAuthMiddleware({
    super.matcher,
    required this.provider,
    this.prefix = const Config.value(''),
    required super.routes,
    super.catchRequests = false,
    super.requireSession = true,
  });

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
