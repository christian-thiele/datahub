import 'package:datahub/api.dart';

class BearerAuthSession extends Session {
  @override
  Stream<void> get expiration => throw UnimplementedError();

  @override
  DateTime get timestamp => throw UnimplementedError();

}