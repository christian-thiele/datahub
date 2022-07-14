import 'package:datahub/api.dart';

class StaticAuthResult extends AuthResult {
  final int userId;

  StaticAuthResult(this.userId);
}
