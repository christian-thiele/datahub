import 'package:cl_datahub/cl_datahub.dart';
import 'package:dart_amqp/dart_amqp.dart';

// TODO documentation, implementation etc
abstract class BrokerService implements BaseService {
  Future<Channel> openChannel();
}
