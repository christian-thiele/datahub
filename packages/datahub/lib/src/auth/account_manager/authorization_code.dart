import 'package:datahub/data.dart';

part 'authorization_code.g.dart';

@Data()
class AuthorizationCode extends $AuthorizationCode {
  @Id()
  final String code;
  final String clientId;
  final String accountId;
  final String challenge;
  final String state;
  final DateTime issuedAt;
  final DateTime validUntil;

  const AuthorizationCode({
    required this.code,
    required this.clientId,
    required this.accountId,
    required this.challenge,
    required this.state,
    required this.issuedAt,
    required this.validUntil,
  });
}
