import 'package:datahub/api.dart';
import 'package:datahub/src/http/bearer_auth.dart';

class BearerTokenTestProvider extends BearerTokenAuthProvider {
  final String token;

  BearerTokenTestProvider(
    super.internal, {
    required this.token,
    super.requireAuthorization,
    super.prefix,
  });

  @override
  Future<BearerAuthSession> getSession(BearerAuth auth) async {
    if (auth.token == token) {
      return BearerAuthSession(auth);
    } else {
      throw ApiRequestException.unauthorized();
    }
  }
}
