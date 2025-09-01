class Authentication {
  final String accessToken;
  final String refreshToken;
  final DateTime expiration;

  Authentication({
    required this.accessToken,
    required this.refreshToken,
    required this.expiration,
  });

  bool get isValid =>
      expiration.isAfter(DateTime.now().add(Duration(minutes: 1)));

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiration': expiration.toIso8601String(),
    };
  }

  factory Authentication.fromJson(Map<String, dynamic> data) {
    return Authentication(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      expiration: DateTime.parse(data['expiration']),
    );
  }
}
