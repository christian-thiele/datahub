import 'package:datahub/datahub.dart';

part 'simple_auth_request.g.dart';

@Data()
class SimpleAuthRequest extends $SimpleAuthRequest {
  final String username;
  final String password;

  const SimpleAuthRequest({required this.username, required this.password});
}
