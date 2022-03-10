import 'package:cl_datahub/cl_datahub.dart';
import 'package:dart_amqp/dart_amqp.dart';

import '../dto/other_dto.dart';
import '../dto/test_dto.dart';

part 'example_api.g.dart';

@BrokerInterface(queueName: 'testapi')
abstract class ExampleApi {
  // fire and forget (just add to queue)
  void doSomething(int x);

  // RPC with reply queue
  Future<OtherDto> getSomeString(TestDto dto);
}

@BrokerApi(queueName: 'testapi')
class ExampleApiImpl extends ExampleApi {
  @override
  void doSomething(int x) {
    print('Received doSomething($x)!');
  }

  @override
  Future<OtherDto> getSomeString(TestDto dto) async {
    print('Received getSomeString("${dto.shortDescription}")');
    print('Waiting 3 secs...');
    await Future.delayed(const Duration(seconds: 3));
    final result = OtherDto(
        dto.shortDescription.toString().toUpperCase(), dto.privacyLevel);
    print('Returning "${result.someStr}');
    return result;
  }
}
