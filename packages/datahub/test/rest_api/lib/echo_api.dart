import 'package:datahub/api.dart';

import 'simple_dto.dart';

class EchoApi extends ApiService {
  EchoApi()
      : super(
          'echoApi',
          [
            EchoEndpoint(),
            ListBodyEndpoint(),
          ],
        );
}

class EchoEndpoint extends ApiEndpoint {
  EchoEndpoint() : super(RoutePattern('/echo'));

  @override
  Future get(ApiRequest request) async {
    await Future.delayed(Duration(milliseconds: 1500));
    return EmptyResponse();
  }

  @override
  Future post(ApiRequest request) async {
    return await request.getBody();
  }

  @override
  Future delete(ApiRequest request) async {}
}

class ListBodyEndpoint extends ApiEndpoint {
  ListBodyEndpoint() : super(RoutePattern('/list'));

  @override
  Future post(ApiRequest request) async {
    return request.getList<SimpleDto>(SimpleDto.bean);
  }
}
