import 'package:datahub/api.dart';
import 'package:datahub/scaffold.dart';

abstract class AuthenticationMiddleware<T extends Session>
    extends ApiMiddleware {
  final bool requireSession;

  const AuthenticationMiddleware({
    super.matcher,
    required super.routes,
    super.catchRequests = false,
    this.requireSession = true,
  });

  @override
  Future<dynamic> onRequest(
    ApiRequest request,
    RequestHandler<ApiResponse> next,
  ) async {
    final session = await authenticate(request);
    if (session != null) {
      return await Context.ofZone().withSession(
        session,
        () async => await next(request),
      );
    } else if (!requireSession) {
      return await next(request);
    }

    throw ApiRequestException.unauthorized();
  }

  Future<T?> authenticate(ApiRequest request);
}
