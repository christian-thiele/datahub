import 'package:datahub_amqp/protocol/connection.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Test Connection', () async {
    final connection = await Connection.open(host: 'localhost', port: 5672);
    await Future.delayed(const Duration(seconds: 2));
  });
}