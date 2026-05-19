import 'package:datahub/datahub.dart';

// TODO make this mixin for custom sessions
class ApertureSession implements Session {
  @override
  String get debugName => 'aperture-auth-${token.sub}';

  final Jwt token;
  @override
  final String identity;
  final String username;

  ApertureSession({
    required this.token,
    required this.identity,
    required this.username,
  });
}
