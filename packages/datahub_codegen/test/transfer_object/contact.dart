import 'package:datahub/datahub.dart';

import 'contact_type.dart';
import 'json_fields.dart';

part 'contact.g.dart';

@TransferObject()
class Contact extends _TransferObject {
  @TransferId()
  final String id;
  final String name;
  final String number;
  final String address;
  final ContactType type;
  final List<int> intList;
  final List<JsonFields> jsonFieldList;
  final List<ContactType> enumList;

  Contact(
    this.id,
    this.name,
    this.number,
    this.address,
    this.intList,
    this.jsonFieldList,
    this.type,
    this.enumList,
  );
}
