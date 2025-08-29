import 'package:datahub/datahub.dart';

import '../transfer_object/contact.dart';

part 'test_hub.g.dart';

@Hub()
abstract class TestHub {
  @HubResource('/contact/{id}')
  ElementResource<Contact> get contact;

  @HubResource('/self')
  MutableElementResource<Contact> get self;

  @HubResource('/contacts')
  CollectionResource<Contact, String> get contacts;
}
