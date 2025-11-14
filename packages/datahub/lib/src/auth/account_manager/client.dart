import 'package:datahub/data.dart';

part 'client.g.dart';

@Data()
class Client extends $Client {
  @Id(auto: true)
  final String id;
  final String name;
  final String? secret;
  final List<String> redirectUris;
  final bool enabled;

  const Client({
    required this.id,
    required this.name,
    required this.secret,
    required this.redirectUris,
    required this.enabled,
  });
}
