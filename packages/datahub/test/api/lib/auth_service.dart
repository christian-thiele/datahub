import 'package:datahub/datahub.dart';

class TestSession(@override final String identity) implements Session {
  @override
  String get debugName => 'Test Session: $identity';
}

class const AuthService() implements Service {
  @override
  ServiceInstance<AuthService> createInstance() => _AuthServiceInstance();
}

class _AuthServiceInstance()
    extends ServiceInstance<AuthService>
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
