import 'http_auth.dart';

class BearerAuth extends HttpAuth {
  final String prefix;
  final String token;

  BearerAuth(this.token, {this.prefix = 'Bearer '});

  @override
  String get authorization => prefix + token;

  @override
  String toString() => authorization;
}