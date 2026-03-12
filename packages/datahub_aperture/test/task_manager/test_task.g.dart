// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_task.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $TestTask with DataObject<TestTask> {
  const $TestTask();
  static const $$codec = JsonDataCodec();
  static final $message = DataField<TestTask, String>(
    name: 'message',
    valueOf: (p) => p.message,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $shouldFail = DataField<TestTask, bool>(
    name: 'shouldFail',
    valueOf: (p) => p.shouldFail,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final DataBean<TestTask> bean = DataBean<TestTask>(
    name: 'TestTask',
    fields: List<DataField<TestTask, dynamic>>.unmodifiable([
      $message,
      $shouldFail,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<TestTask, dynamic>> get $$fields => bean.fields;
  TestTask copyWith({String? message, bool? shouldFail}) {
    final $data = this as TestTask;
    return TestTask(
      message: message ?? $data.message,
      shouldFail: shouldFail ?? $data.shouldFail,
    );
  }

  static TestTask fromValues(Map<String, dynamic> data) {
    return TestTask(message: data['message'], shouldFail: data['shouldFail']);
  }

  static TestTask fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(TestTask, data.runtimeType, name);
    }
    return TestTask(
      message: $message.fromJson(
        data['message'],
        name: DataCodec.childName(name, 'message'),
      ),
      shouldFail: $shouldFail.fromJson(
        data['shouldFail'],
        name: DataCodec.childName(name, 'shouldFail'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as TestTask;
    return {
      'message': $message.toJson($$data.message),
      'shouldFail': $shouldFail.toJson($$data.shouldFail),
    }..removeWhere((k, v) => v == null);
  }
}
