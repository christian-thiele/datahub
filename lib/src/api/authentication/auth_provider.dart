import 'package:datahub/api.dart';

/// [AuthProvider] handles the authorization of requests.
///
/// Use an [AuthProvider] implementation as middleware in an [ApiService].
/// See also:
///   - [JWTAuthProvider]
///   - [BasicAuthProvider]
///   - [BearerTokenAuthProvider]
///
/// An [AuthProvider] handles authorization and populates the
/// [ApiRequest.session] property as a result.
///
/// If [requireAuthorization] is set to false, a request without valid
/// authorization is not immediately discarded with HTTP status code 401
/// but instead forwarded to the [RequestHandler] with
/// [ApiRequest.session] = null.
abstract class AuthProvider extends Middleware {
  final bool requireAuthorization;

  AuthProvider(super.internal, {this.requireAuthorization = true});

  Future<Session?> authorizeRequest(ApiRequest request);

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async {
    final session = await authorizeRequest(request);
    if (requireAuthorization && session == null) {
      throw ApiRequestException.unauthorized();
    }

    return await next(request.withSession(session));
  }
}
