import 'package:datahub/data.dart';

part 'address.g.dart';

@Data()
class Address extends $Address {
  const Address({
    required this.recipient,
    this.attention,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.country,
  });

  final String recipient;

  @Meta(name: 'Attn.')
  final String? attention;

  final String street;

  @Meta(name: 'Postal code')
  final String postalCode;

  final String city;

  @RegExpConstraint(expression: r'^[A-Z]{2}$')
  final String country;
}
