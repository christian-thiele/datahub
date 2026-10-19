import 'package:datahub/datahub.dart';

// TODO make this mixin for custom sessions
class ApertureSession({
  required final Jwt token,
  @override required final String identity,
  required final String username,
}) implements Session {
  @override
  String get debugName => 'aperture-auth-${token.sub}';
}
