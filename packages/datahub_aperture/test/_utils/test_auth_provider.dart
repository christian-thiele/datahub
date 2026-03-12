import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/services.dart';

class TestAuthProvider implements Service {
  @override
  ServiceInstance<Service> createInstance() => _TestAuthProviderInstance();
}

class _TestAuthProviderInstance extends ServiceInstance<TestAuthProvider>
    implements JwtAuthProvider {
  @override
  Future<Session> authenticateJwt(Jwt auth) async {
    return ApertureSession(
      token: auth,
      identity: auth.sub!,
      username: auth.payload['email'],
    );
  }
}
