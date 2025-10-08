import 'package:datahub/auth.dart';

class Authentication {
  final Jwt accessToken;
  final String refreshToken;

  Authentication({required this.accessToken, required this.refreshToken});

  bool get isValid =>
      accessToken.exp?.isAfter(DateTime.now().add(Duration(minutes: 1))) ??
      true;

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken.token, 'refreshToken': refreshToken};
  }

  factory Authentication.fromJson(Map<String, dynamic> data) {
    return Authentication(
      accessToken: Jwt(data['accessToken']),
      refreshToken: data['refreshToken'],
    );
  }
}
