import 'package:datahub/datahub.dart';

part 'simple_auth_refresh_request.g.dart';

@Data()
class SimpleAuthRefreshRequest extends $SimpleAuthRefreshRequest {
  final String refreshToken;

  const SimpleAuthRefreshRequest({
    required this.refreshToken,
  });
}
