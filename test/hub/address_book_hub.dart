import 'package:datahub/api.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/src/hub/hub_resource.dart';
import 'package:datahub/src/hub/resource.dart';
import 'package:datahub/src/hub/rest/rest_client.dart';

import 'contact.dart';

abstract class AddressBookHub {
  @HubResource('/readonly')
  Resource<Contact> get readOnly;

  @HubResource('/self')
  MutableResource<Contact> get self;
}

/// GENERATED
class AddressBookHubClient extends RestClient implements AddressBookHub {
  @override
  late final Resource<Contact> readOnly = ResourceRestClient(
    this,
    RoutePattern('/readonly'),
    ContactTransferBean,
  );

  @override
  late final MutableResource<Contact> self = MutableResourceRestClient(
    this,
    RoutePattern('/readonly'),
    ContactTransferBean,
  );
}

void test() {
  final hub = AddressBookHubClient(); //resolve


}
