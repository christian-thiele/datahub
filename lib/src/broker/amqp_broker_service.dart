import 'package:cl_datahub/cl_datahub.dart';
import 'package:dart_amqp/dart_amqp.dart';

import 'broker_service.dart';

class AmqpBrokerService implements BrokerService {
  final _logService = resolve<LogService>();
  final _config = ConfigService.resolve<BrokerConfig>();

  late final Client _client;

  AmqpBrokerService();

  @override
  Future<void> initialize() async {
    final settings = ConnectionSettings(
      host: _config.brokerHost,
      port: _config.brokerPort,
      authProvider: PlainAuthenticator(
        _config.brokerUser,
        _config.brokerPassword,
      ),
    );
    _client = Client(settings: settings);
    _logService.info('AMQP Broker Service initialized.', sender: 'DataHub');
  }

  @override
  Future<Channel> openChannel() async => await _client.channel();

  @override
  Future<void> shutdown() async {
    await _client.close();
  }
}
