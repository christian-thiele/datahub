import 'dart:typed_data';

import 'package:datahub/data.dart';

part 'person.g.dart';

@Data()
abstract class Person with _Person {
  const factory Person({
    int id,
    required String firstName,
    required String lastName,
    required List<String> phone,
    required List<String> email,
    required DateTime? birthday,
    required bool isBlocked,
    required Uint8List picture,
  }) = $Person.new;
}
