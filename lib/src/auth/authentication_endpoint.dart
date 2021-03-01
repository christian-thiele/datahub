import 'package:boost/boost.dart';
import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/api_error.dart';

class AuthenticationEndpoint extends ApiEndpoint {
  AuthenticationEndpoint(RoutePattern routePattern) : super(routePattern); //TODO authentication provider

  @override
  Future post(ApiRequest request) async {
    if (request.context.sessionProvider == null) {
      throw ApiError(
          'Cannot use AuthenticationEndpoint without SessionProvider!');
    }

    final body = request.getJsonBody();
    if (body is! Map<String, dynamic>) {
      throw ApiRequestException.badRequest();
    }

    if (!body.containsKey('method')) {
      throw ApiRequestException.badRequest('No authentication method specified.');
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
      final userId = 1; //TODO fetch userId while authenticating

      if (authenticated) {
        final session =
            await request.context.sessionProvider!.createSession(userId);
        //TODO set session as cookie if configured to do so
        return {
          'session-token': session.sessionToken
        };
      } else {
        throw ApiRequestException.unauthorized('Invalid credentials.');
      }
    }

    //TODO login with oauth / other methods / auth provider / whatever

    throw ApiRequestException.badRequest('Could not find login method: ${body['method']}');
  }
}
