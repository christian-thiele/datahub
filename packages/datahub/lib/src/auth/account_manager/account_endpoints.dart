import 'package:datahub/api.dart';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';

import 'account_manager_service.dart';

class AccountEndpoints extends ApiNode {
  final Config<String> basePath;
  final Find<AccountManager> accountManager;

  const AccountEndpoints({
    this.accountManager = const Find(),
    this.basePath = const Config.value(''),
  });

  @override
  List<ApiRoute> buildRoutes() {
    final base = basePath.read();
    final accounts = accountManager.find();
    return [
      ResourceEndpoint(
        matcher: RoutePattern('$base/.well-known/openid-configuration'),
        get: (request) async => accounts.getOpenIdConfiguration(),
      ),
      ResourceEndpoint(
        matcher: RoutePattern('$base/oidc/jwks'),
        get: (request) async => {'keys': accounts.getKeySet()},
      ),
      ResourceEndpoint(
        matcher: RoutePattern('$base/oidc/auth'),
        get: accounts.authorizeRequest,
        post: accounts.authorizeRequest,
      ),
      ResourceEndpoint(
        matcher: RoutePattern('$base/oidc/token'),
        post: accounts.tokenRequest,
      )
    ];
  }
}
