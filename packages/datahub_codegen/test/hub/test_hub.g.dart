// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_hub.dart';

// **************************************************************************
// HubClientGenerator
// **************************************************************************

class TestHubClient extends HubClient<TestHub> implements TestHub {
  final RestClient _client;
  final String basePath;
  TestHubClient(this._client, {this.basePath = ''});
  @override
  late final ElementResourceClient<Contact> contact = ElementResourceRestClient(
    _client,
    RoutePattern('$basePath/contact/{id}'),
    ContactTransferBean,
  );
  @override
  late final MutableElementResourceClient<Contact> self =
      MutableElementResourceRestClient(
    _client,
    RoutePattern('$basePath/self'),
    ContactTransferBean,
  );
  @override
  late final CollectionResourceClient<Contact, String> contacts =
      CollectionResourceRestClient(
    _client,
    RoutePattern('$basePath/contacts'),
    ContactTransferBean,
  );
  @override
  Future<void> closeAll() async {
    await contact.closeAll();
    await self.closeAll();
    await contacts.closeAll();
  }

  @override
  Future<void> reconnectAll() async {
    await contact.reconnectAll();
    await self.reconnectAll();
    await contacts.reconnectAll();
  }
}

// **************************************************************************
// HubProviderGenerator
// **************************************************************************

abstract class TestHubProvider extends HubProvider<TestHub> implements TestHub {
  TestHubProvider();

  @override
  late final ElementResourceProvider<Contact> contact = ElementResourceAdapter(
    RoutePattern('/contact/{id}'),
    ContactTransferBean,
    getContact,
    getContactStream,
  );

  @override
  late final MutableElementResourceProvider<Contact> self =
      MutableElementResourceAdapter(
    RoutePattern('/self'),
    ContactTransferBean,
    getSelf,
    setSelf,
    getSelfStream,
  );

  @override
  late final CollectionResourceProvider<Contact, String> contacts =
      CollectionResourceAdapter(
    RoutePattern('/contacts'),
    ContactTransferBean,
    getContactsWindow,
  );

  @override
  List<ResourceProvider> get resources => [
        contact,
        self,
        contacts,
      ];

  Future<Contact> getContact(ApiRequest request);

  Stream<Contact> getContactStream(ApiRequest request);

  Future<Contact> getSelf(ApiRequest request);

  Future<void> setSelf(ApiRequest request, Contact value);

  Stream<Contact> getSelfStream(ApiRequest request);

  Stream<CollectionWindowEvent<Contact, String>> getContactsWindow(
      ApiRequest request, int offset, int length);
}
