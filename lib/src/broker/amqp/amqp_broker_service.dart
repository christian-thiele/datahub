import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:datahub/src/broker/amqp/amqp_broker_channel.dart';

import '../broker_service.dart';

/// Implements [BrokerService] as an AMQP client using dart_amqp lib.
///
/// Configuration values:
///   `host`: Broker connection host
///   `port`: Broker connection port (optional, default 5672)
///   `user`: Username for authentication at broker
///   `password`: Password for authentication at broker
///   `heartbeatPeriod`: Milliseconds between heartbeats (optional, default 5000)
class AmqpBrokerService extends BrokerService {
  final _logService = resolve<LogService>();

  late final _configHost = config<String>('host');
  late final _configPort = config<int?>('port') ?? 5672;
  late final _configUser = config<String>('user');
  late final _configPassword = config<String>('password');
  late final _heartbeatPeriod = config<int?>('heartbeatPeriod') ?? 3000;
  late final _connectionName = config<String?>('connectionName');

  late final Client _client;

  AmqpBrokerService([String? path]) : super(path);

  @override
  Future<void> initialize() async {
    final settings = ConnectionSettings(
      host: _configHost,
      port: _configPort,
      tuningSettings: TuningSettings(
        heartbeatPeriod: Duration(milliseconds: _heartbeatPeriod),
      ),
      authProvider: PlainAuthenticator(
        _configUser,
        _configPassword,
      ),
      connectionName: _connectionName ?? resolve<ConfigService>().serviceName,
    );

    _client = Client(settings: settings);
    _client.errorListener((error) {
      _logService.error('Error in AMQP Broker Client.', error: error);
    });
    _logService.verbose('AMQP Broker Service initialized.', sender: 'DataHub');
  }

  @override
  Future<AmqpBrokerChannel> openChannel({int? prefetch}) async =>
      AmqpBrokerChannel(
          await _client.channel().then((c) => c.qos(0, prefetch)));

  @override
  Future<void> shutdown() async {
    await _client.close();
  }
}
