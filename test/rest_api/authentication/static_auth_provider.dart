import 'package:cl_datahub/src/api/api_request_exception.dart';
import 'package:cl_datahub/src/api/authentication/auth_provider.dart';

import 'static_auth_result.dart';

/// Basic [AuthProvider] implementation that authenticates using a given list
/// of user models with username and password.
class StaticAuthProvider extends AuthProvider<StaticAuthResult> {
  final List<StaticAuthUser> users;

  StaticAuthProvider(this.users);

  @override
  Future<StaticAuthResult> authenticate(Map<String, dynamic> authData) async {
    final username = authData['username']?.toString() ??
        (throw ApiRequestException.badRequest(
            'Missing username in auth data.'));

    final password = authData['password']?.toString() ??
        (throw ApiRequestException.badRequest(
            'Missing password in auth data.'));

    final user = users.firstWhere(
        (u) => u.username.toLowerCase() == username.toLowerCase(),
        orElse: () => throw ApiRequestException.unauthorized());

    if (user.password != password) {
      throw ApiRequestException.unauthorized();
    }

    return StaticAuthResult(user.id);
  }
}

class StaticAuthUser {
  final int id;
  final String username;
  final String password;

  StaticAuthUser(this.id, this.username, this.password);
}
