import 'package:datahub/api.dart';
import 'package:datahub/http.dart';

abstract class BearerAuthSession extends Session {
  final BearerAuth token;

  BearerAuthSession(this.token);
}
