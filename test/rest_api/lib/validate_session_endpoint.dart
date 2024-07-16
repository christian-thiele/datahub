import 'package:datahub/api.dart';

class ValidateSessionEndpoint<T extends Session> extends ApiEndpoint {
  final bool Function(T) validate;

  ValidateSessionEndpoint(super.routePattern, {required this.validate});

  @override
  Future get(ApiRequest request) async {
    final session = request.getSession<T>();
    if (!validate(session)) {
      throw ApiRequestException.unauthorized();
    }
  }
}
