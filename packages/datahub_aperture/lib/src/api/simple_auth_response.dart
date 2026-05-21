import 'package:datahub/datahub.dart';

part 'simple_auth_response.g.dart';

@Data()
class SimpleAuthResponse extends $SimpleAuthResponse {
  final String accessToken;
  final String refreshToken;

  const SimpleAuthResponse({
    required this.accessToken,
    required this.refreshToken,
  });
}
