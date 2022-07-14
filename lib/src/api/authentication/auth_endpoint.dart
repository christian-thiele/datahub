import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/utils.dart';

class AuthEndpoint extends ApiEndpoint {
  final Map<String, AuthProvider> _providers;

  AuthEndpoint(RoutePattern routePattern, this._providers)
      : super(routePattern);

  @override
  Future post(ApiRequest request) async {
    if (request.context.sessionProvider == null) {
      throw ApiError('Cannot use AuthEndpoint without SessionProvider!');
    }

    final body = await request.getJsonBody();

    if (!body.containsKey('method')) {
      throw ApiRequestException.badRequest(
          'No authentication method specified.');
    }

    if (!body.containsKey('data')) {
      throw ApiRequestException.badRequest('No authentication data provided.');
    }

    final provider =
        _providers.entries.firstOrNullWhere((p) => p.key == body['method']);

    if (provider == null) {
      throw ApiRequestException.badRequest(
          'No matching authentication method found.');
    }

    //will throw when authentication not possible
    final authResult = await provider.value.authenticate(body['data']);

    final session =
        await request.context.sessionProvider!.createSession(authResult);
    //TODO set session as cookie if configured to do so
    return <String, dynamic>{'session-token': session.sessionToken}
      ..addAll(authResult.clientData);
  }
}
