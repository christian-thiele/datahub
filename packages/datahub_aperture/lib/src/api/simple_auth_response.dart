import 'package:datahub/datahub.dart';

part 'simple_auth_response.g.dart';

@Data()
class const SimpleAuthResponse({
  required final String accessToken,
  required final String refreshToken,
}) extends $SimpleAuthResponse;
