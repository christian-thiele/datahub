class AmqpException {
  final int errorCode;
  final String message;

  AmqpException({required this.errorCode, required this.message});
}
