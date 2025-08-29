import 'package:datahub/datahub.dart';

import '../transfer_object/contact.dart';

part 'json_fields.g.dart';

@DaoType()
class JsonFields extends _Dao {
  final List dynamicList;
  final List? dynamicListNullable;

  final List<String> typedList;
  final List<String>? typedListNullable;

  final Map<String, dynamic> dynamicMap;
  final Map<String, dynamic>? dynamicMapNullable;

  final Map<String, String> typedMap;
  final Map<String, String>? typedMapNullable;

  final Contact contact;
  final Contact? contactNullable;
  final List<Contact> contacts;
  final List<Contact?> contactsNullable;
  final List<Contact>? contactsNullable2;

  JsonFields({
    required this.dynamicList,
    required this.dynamicListNullable,
    required this.typedList,
    required this.typedListNullable,
    required this.dynamicMap,
    required this.dynamicMapNullable,
    required this.typedMap,
    required this.typedMapNullable,
    required this.contact,
    required this.contactNullable,
    required this.contacts,
    required this.contactsNullable,
    required this.contactsNullable2,
  });
}
