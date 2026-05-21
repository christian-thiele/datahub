import 'package:datahub/datahub.dart';

class TestSession implements Session {
  @override
  String get debugName => 'Test Session: $identity';

  @override
  final String identity;

  TestSession(this.identity);
}

class AuthService implements Service {
  const AuthService();

  @override
  ServiceInstance<AuthService> createInstance() => _AuthServiceInstance();
}

class _AuthServiceInstance extends ServiceInstance<AuthService>
    implements BasicAuthProvider {
  @override
  Future<TestSession> authenticateBasic(BasicAuth auth) async {
    if (auth.username == auth.password.split('').reversed.join()) {
      return TestSession(auth.username);
    } else {
      throw ApiRequestException.unauthorized();
    }
  }
}
