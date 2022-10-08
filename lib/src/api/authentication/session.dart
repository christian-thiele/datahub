import 'package:rxdart/rxdart.dart';

abstract class Session {
  DateTime get timestamp;
  Stream<void> get expiration;
}