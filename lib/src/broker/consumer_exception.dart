/// Exception can be used to control message ack behaviour.
///
/// When this exception is thrown inside a BrokerAPI consumer method,
/// the message will be rejected. If [requeue] is true, the message will
/// be requeued for either this or another consumer to try processing it again.
class ConsumerException implements Exception {
  final String message;
  final bool requeue;

  ConsumerException(this.message, {this.requeue = false});

  @override
  String toString() => message;
}
