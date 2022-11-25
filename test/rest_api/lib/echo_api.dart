import 'package:datahub/api.dart';

class EchoApi extends ApiService {
  EchoApi() : super('echoApi', [EchoEndpoint()]);
}

class EchoEndpoint extends ApiEndpoint {
  EchoEndpoint() : super(RoutePattern('/echo'));

  @override
  Future get(ApiRequest request) async => EmptyResponse();

  @override
  Future post(ApiRequest request) async {
    return await request.getBody();
  }

  @override
  Future delete(ApiRequest request) async {}
}
