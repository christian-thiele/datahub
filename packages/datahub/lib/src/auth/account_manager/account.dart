import 'package:datahub/data.dart';

part 'account.g.dart';

@Data()
class Account extends $Account {
  @Id(auto: true)
  final String id;

  final String email;
  final String? password;
  final bool allowSignIn;
  final DateTime createdAt;

  const Account({
    this.id = '',
    required this.email,
    this.password,
    required this.allowSignIn,
    required this.createdAt,
  });
}
