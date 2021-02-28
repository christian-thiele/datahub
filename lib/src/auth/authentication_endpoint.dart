import 'package:boost/boost.dart';
import 'package:cl_datahub/api.dart';

class AuthenticationEndpoint extends ApiEndpoint {
  AuthenticationEndpoint(RoutePattern routePattern) : super(routePattern);

  @override
  Future post(ApiRequest request) async {
    final body = request.getJsonBody();
    if (body is! Map<String, dynamic>) {
      throw ApiRequestException.badRequest();
    }

    if (body['method'] == null || body['method'] == 'credentials') {
      // credentials login
      final userName = body['user'] as String?;
      final password = body['password'] as String?;
      if (nullOrEmpty(userName) || nullOrEmpty(password)) {
        throw ApiRequestException.badRequest();
      }

      //TODO authenticate user with userName + password
      final authenticated = true;
      if (authenticated) {
        //TODO create session
        //TODO "set" session
        //TODO return session token
      }else{
        throw ApiRequestException.unauthorized('Invalid credentials.');
      }

    }

    //TODO login with oauth

  }
}