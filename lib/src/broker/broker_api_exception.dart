class BrokerApiException implements Exception {
  final int? errorCode;
  final String message;

  BrokerApiException(this.message, {this.errorCode});

  @override
  String toString() {
    if (errorCode != null) {
      return 'BrokerApiException: [$errorCode] $message';
    } else {
      return 'BrokerApiException: $message';
    }
  }

  Map<String, dynamic> toPayload() =>
      {'error': message, 'errorCode': errorCode};
}
