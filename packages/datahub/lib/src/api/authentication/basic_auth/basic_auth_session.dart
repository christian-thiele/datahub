import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:rxdart/rxdart.dart';

class BasicAuthSession extends Session {
  final BasicAuth basicAuth;

  BasicAuthSession(this.basicAuth);

  @override
  DateTime get timestamp => DateTime.now();

  @override
  Stream<void> get expiration => Rx.never();
}
