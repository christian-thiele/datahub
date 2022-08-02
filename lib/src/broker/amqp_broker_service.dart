import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:dart_amqp/dart_amqp.dart';

import 'broker_service.dart';

/// Implements [BrokerService] as an AMQP client.
///
/// Configuration values:
///   `host`: Broker connection host
///   `port`: Broker connection port (optional)
///   `user`: Username for authentication at broker
///   `password`: Password for authentication at broker
class AmqpBrokerService extends BrokerService {
  final _logService = resolve<LogService>();

  late final _configHost = config<String>('host');
  late final _configPort = config<int?>('port') ?? 5672;
  late final _configUser = config<String>('user');
  late final _configPassword = config<String>('password');

  late final Client _client;

  AmqpBrokerService([String? path]) : super(path);

  @override
  Future<void> initialize() async {
    final settings = ConnectionSettings(
      host: _configHost,
      port: _configPort,
      authProvider: PlainAuthenticator(
        _configUser,
        _configPassword,
      ),
    );

    _client = Client(settings: settings);
    _logService.verbose('AMQP Broker Service initialized.', sender: 'DataHub');
  }

  @override
  Future<Channel> openChannel() async => await _client.channel();

  @override
  Future<void> shutdown() async {
    await _client.close();
  }
}
