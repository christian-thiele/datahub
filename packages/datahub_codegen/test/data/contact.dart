// @dart=3.13
import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';

import 'contact_type.dart';

part 'contact.g.dart';

/// Data class using a const primary constructor with named parameters.
@Data()
class const Contact({
  @Id() final int id = 0,
  @JsonKey('display_name') required final String name,
  @MinLengthConstraint(length: 3) required final String email,
  final ContactType? type,
  final List<String> tags = const [],
  required final String _note,
}) extends $Contact {
  String get note => _note;
}

/// Data class using a const primary constructor with positional parameters.
@Data()
class const Vector(final int x, final int y, [final int? z]) extends $Vector;

/// Data class using a named const primary constructor.
@Data(defaultNamingConvention: NamingConvention.lowerSnakeCase)
class const Address.create({
  required final String streetName,
  final int? houseNumber,
}) extends $Address;
