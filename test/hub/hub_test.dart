import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/src/hub/hub.dart';
import 'package:datahub/src/hub/hub_client.dart';
import 'package:datahub/src/hub/hub_provider.dart';
import 'package:datahub/src/hub/resource_adapter.dart';
import 'package:test/test.dart';

import 'package:datahub/src/hub/hub_resource.dart';
import 'package:datahub/src/hub/resource.dart';
import 'package:datahub/src/hub/rest/resource_rest_client.dart';
import 'package:datahub/src/hub/rest/resource_rest_endpoint.dart';

import 'contact.dart';

@Hub()
abstract class TestHub {
  @HubResource('/contact/{id}')
  Resource<Contact> get contact;
}

/// GENERATED
class TestHubClient extends HubClient<TestHub> implements TestHub {
  final RestClient _restClient; //TODO abstract for protocol agnostic client

  TestHubClient(this._restClient);

  @override
  late final MutableResource<Contact> contact = MutableResourceRestClient(
    _restClient,
    RoutePattern('/contact/{id}'),
    ContactTransferBean,
  );
}

/// GENERATED
abstract class TestHubProvider extends HubProvider<TestHub> implements TestHub {
  TestHubProvider();

  @override
  late final MutableResource<Contact> contact = MutableResourceAdapter(
    RoutePattern('/contact/{id}'),
    ContactTransferBean,
    getContact,
    setContact,
    getContactStream,
  );

  @override
  List<Resource<TransferObjectBase>> get resources => [contact];

  // mutable methods
  Future<Contact> getContact(Map<String, String> params);

  Future<void> setContact(Contact value, Map<String, String> params);

  Stream<Contact> getContactStream(Map<String, String> params);
}

// implementation
class TestHubProviderImpl extends TestHubProvider {
  final _contacts = <String, Contact>{};
  final _contactChanged = StreamController<Contact>.broadcast();

  @override
  Future<Contact> getContact(Map<String, String> params) async {
    return _contacts[params['id']] ?? (throw ApiRequestException.notFound());
  }

  @override
  Stream<Contact> getContactStream(Map<String, String> params) async* {
    yield* _contactChanged.stream.where((event) => event.id == params['id']);
  }

  @override
  Future<void> setContact(Contact value, Map<String, String> params) async {
    final id = params['id']!;
    _contacts[id] = value;
    _contactChanged.add(value.copyWith(id: id));
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> shutdown() async {}
}

void main() {
  test('test', _test, timeout: Timeout.none);
}

Future<void> _test() async {
  final token = CancellationToken();
  final serviceHost = ServiceHost([
    TestHubProviderImpl.new,
    () => ApiService(
          null,
          [
            ...ResourceRestEndpoint.allOf<TestHub>(),
          ],
        ),
  ], catchSignal: false, onInitialized: () async {
    final client =
        await RestClient.connectHttp2(Uri.parse('http://localhost:8080'));

    final hub = TestHubClient(client); //resolve

    await hub.contact.set(Contact('1', 'You', '12345', 'Street'), {'id': '1'});

    final simple = await hub.contact.get({'id': '1'});
    expect(simple.name, equals('You'));

    final resultTask = hub.contact.getStream({'id': '1'}).take(3).toList();

    await Future.delayed(const Duration(seconds: 1));
    await hub.contact
        .set(Contact('1', 'Me', '12345', 'Street 123'), {'id': '1'});
    await Future.delayed(const Duration(milliseconds: 1));
    await hub.contact.set(Contact('2', 'xxx', 'xxxxx', 'xxxx'), {'id': '2'});
    await Future.delayed(const Duration(milliseconds: 1));
    await hub.contact
        .set(Contact('1', 'Me', '123456', 'Street 123'), {'id': '1'});

    final streamList = await resultTask;
    expect(streamList.length, equals(3));
    expect(streamList.first.name, equals('You'));
    expect(streamList.first.number, equals('12345'));
    expect(streamList.first.address, equals('Street'));
    expect(streamList[1].number, equals('12345'));
    expect(streamList[1].address, equals('Street 123'));
    expect(streamList[2].number, equals('123456'));
    expect(streamList[2].address, equals('Street 123'));

    // end server
    token.cancel();
  });
  await serviceHost.run(token);
}
