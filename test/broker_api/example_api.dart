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

  // enum serialization
  Future<String> getEnumName(TestDto dto);

  // multiple params
  Future<OtherDto> getSomeMoreSync(
      TestDto dto1, TestDto dto2, String someString);

  // error
  Future<OtherDto> getSomeNotWorking(int type);

  // fire and forget with error
  void doSomethingAndFail(int x);
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
    print('Waiting 1 sec...');
    await Future.delayed(const Duration(seconds: 1));
    final result = OtherDto(
        dto.shortDescription.toString().toUpperCase(), dto.privacyLevel);
    print('Returning "${result.someStr}"');
    return result;
  }

  @override
  Future<String> getEnumName(TestDto dto) async {
    print('Received getSomeString("${dto.shortDescription}")');
    print('Waiting 1 sec...');
    await Future.delayed(const Duration(seconds: 1));
    final result = dto.category.toString();
    print('Returning "$result"');
    return result;
  }

  @override
  Future<OtherDto> getSomeMoreSync(
      TestDto dto1, TestDto dto2, String someString) async {
    return OtherDto(
        dto1.shortDescription.toString() +
            dto2.shortDescription.toString() +
            someString,
        55);
  }

  @override
  Future<OtherDto> getSomeNotWorking(int type) async {
    print('Waiting 1 sec...');
    await Future.delayed(Duration(seconds: 1));
    print('Throwing error ($type).');
    if (type == 1) {
      throw ApiRequestException(20, 'This did not work.');
    } else {
      throw Exception('This did not work at all.');
    }
  }

  @override
  Future<void> doSomethingAndFail(int x) async {
    await Future.delayed(Duration(milliseconds: 100));
    throw Exception('well...');
  }
}
