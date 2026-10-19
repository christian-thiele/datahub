import 'package:datahub/data.dart';

part 'address.g.dart';

@Data()
class const Address({
  required final String recipient,
  @Meta(name: 'Attn.') final String? attention,
  required final String street,
  @Meta(name: 'Postal code') required final String postalCode,
  required final String city,
  @RegExpConstraint(expression: r'^[A-Z]{2}$') required final String country,
}) extends $Address;
