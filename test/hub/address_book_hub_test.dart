import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/rest_client.dart';
import 'package:test/test.dart';

import 'package:datahub/src/hub/hub_resource.dart';
import 'package:datahub/src/hub/resource.dart';
import 'package:datahub/src/hub/rest/resource_rest_client.dart';
import 'package:datahub/src/hub/rest/resource_rest_endpoint.dart';

import 'contact.dart';

abstract class AddressBookHub {
  @HubResource('/readonly')
  Resource<Contact> get readOnly;

  @HubResource('/self')
  MutableResource<Contact> get self;
}

/// GENERATED
class AddressBookHubClient implements AddressBookHub {
  final RestClient _restClient; //TODO abstract for protocol agnostic client

  AddressBookHubClient(this._restClient);

  @override
  late final Resource<Contact> readOnly = ResourceRestClient(
    _restClient,
    RoutePattern('/readonly'),
    ContactTransferBean,
  );

  @override
  late final MutableResource<Contact> self = MutableResourceRestClient(
    _restClient,
    RoutePattern('/self'),
    ContactTransferBean,
  );
}

void main() {
  test('test', _test, timeout: Timeout.none);
}

Future<void> _test() async {
  final resSource = StreamController<Contact>();
  resSource.add(Contact('1', 'You', '12345', 'Street'));

  final token = CancellationToken();
  final serviceHost = ServiceHost(
    [
      () => ApiService(
            null,
            [
              ResourceRestEndpoint<Contact>(
                  RoutePattern('/self'), resSource.stream),
            ],
          ),
    ],
    catchSignal: false,
    onInitialized: () async {
      final client = await RestClient.connectHttp2(Uri.parse('http://localhost:8080'));
      final hub = AddressBookHubClient(client); //resolve
      final simple = await hub.self.get();
      expect(simple.name, equals('You'));

      final resultTask = hub.self.stream.take(4).toList();

      await Future.delayed(const Duration(seconds: 1));
      resSource.add(Contact('1', 'Me', '12345', 'Street'));
      await Future.delayed(const Duration(milliseconds: 1));
      resSource.add(Contact('1', 'Me', '12345', 'Street 123'));
      await Future.delayed(const Duration(milliseconds: 1));
      resSource.add(Contact('1', 'Me', '123456', 'Street 123'));

      final streamList = await resultTask;
      expect(streamList.length, equals(4));
      expect(streamList.first.name, equals('You'));
      expect(streamList[1].name, equals('Me'));
      expect(streamList[2].number, equals('12345'));
      expect(streamList[2].address, equals('Street 123'));
      expect(streamList[3].number, equals('123456'));
      expect(streamList[3].address, equals('Street 123'));

      // end server
      token.cancel();
    }
  );
  await serviceHost.run(token);
}
