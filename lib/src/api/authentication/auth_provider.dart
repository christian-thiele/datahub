import 'package:datahub/api.dart';

abstract class AuthProvider extends Middleware {
  final bool requireAuthentication;

  AuthProvider(super.internal, {this.requireAuthentication = true});

  Future<Session?> authenticateRequest(ApiRequest request);

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async {
    final session = await authenticateRequest(request);
    if (requireAuthentication && session == null) {
      throw ApiRequestException.unauthorized();
    }

    return await next(request.withSession(session));
  }
}
