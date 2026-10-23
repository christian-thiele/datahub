import 'package:datahub/api.dart';
import 'package:datahub/scaffold.dart';

abstract class const AuthenticationMiddleware<T extends Session>({
  super.matcher,
  required super.routes,
  super.catchRequests = false,
  final bool requireSession = true,
}) extends ApiMiddleware {
  @override
  Future<dynamic> onRequest(
    ApiRequest request,
    RequestHandler<ApiResponse> next,
  ) async {
    final session = await authenticate(request);
    if (session != null) {
      request.session = session;
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
