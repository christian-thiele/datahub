import 'package:datahub/src/hub/hub_resource.dart';

import 'package:datahub/datahub.dart';

part 'contact.g.dart';

@TransferObject()
class Contact extends _TransferObject {
  @TransferId()
  final String id;
  final String name;
  final String number;
  final String address;

  Contact(this.id, this.name, this.number, this.address);
}


