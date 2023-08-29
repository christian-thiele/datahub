//TODO maybe not abstract
//TODO docs
import 'dart:typed_data';

abstract class BrokerMessage {
  Uint8List get payload;
  void ack();
  void reject({bool requeue = false});
}