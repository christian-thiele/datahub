import 'package:datahub/datahub.dart';

part 'simple_auth_request.g.dart';

@Data()
class const SimpleAuthRequest({
  required final String username,
  required final String password,
}) extends $SimpleAuthRequest;
