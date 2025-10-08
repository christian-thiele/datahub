import 'package:datahub/datahub.dart';

class TestSession implements Session {
  @override
  final String debugName = 'Test Session';

  final String user;

  TestSession(this.user);
}

class AuthService implements Service {
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
