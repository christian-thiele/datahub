import 'dart:typed_data';

import 'package:datahub/data.dart';

import 'contact_type.dart' as ext;

part 'person.g.dart';

@Data()
class const Person({
  final int id = 0,
  required final String firstName,
  required final String lastName,
  required final List<String> phone,
  required final List<String> email,
  required final DateTime? birthday,
  required final bool isBlocked,
  required final Uint8List picture,
  required final ext.ContactType? type,
  final Map<String, ext.ContactType> contacts = const {},
}) extends $Person;
