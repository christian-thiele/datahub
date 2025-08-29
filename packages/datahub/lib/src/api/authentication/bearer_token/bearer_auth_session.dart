import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:rxdart/rxdart.dart';

class BearerAuthSession extends Session {
  final DateTime _timestamp;
  final BearerAuth token;

  BearerAuthSession(this.token) : _timestamp = DateTime.timestamp();

  @override
  Stream<void> get expiration => NeverStream();

  @override
  DateTime get timestamp => _timestamp;
}
