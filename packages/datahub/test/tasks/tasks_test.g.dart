// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_test.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $TestJob with DataObject<TestJob> {
  const $TestJob();
  static const $$codec = JsonDataCodec();
  static final $param1 = DataField<TestJob, String>(
    name: 'param1',
    valueOf: (p) => p.param1,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $param2 = DataField<TestJob, int>(
    name: 'param2',
    valueOf: (p) => p.param2,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final DataBean<TestJob> bean = DataBean<TestJob>(
    name: 'TestJob',
    fields: List<DataField<TestJob, dynamic>>.unmodifiable([$param1, $param2]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<TestJob, dynamic>> get $$fields => bean.fields;
  TestJob copyWith({String? param1, int? param2}) {
    final $data = this as TestJob;
    return TestJob(
      param1: param1 ?? $data.param1,
      param2: param2 ?? $data.param2,
    );
  }

  static TestJob fromValues(Map<String, dynamic> data) {
    return TestJob(param1: data['param1'], param2: data['param2']);
  }

  static TestJob fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(TestJob, data.runtimeType, name);
    }
    return TestJob(
      param1: $param1.fromJson(
        data['param1'],
        name: DataCodec.childName(name, 'param1'),
      ),
      param2: $param2.fromJson(
        data['param2'],
        name: DataCodec.childName(name, 'param2'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as TestJob;
    return {
      'param1': $param1.toJson($$data.param1),
      'param2': $param2.toJson($$data.param2),
    }..removeWhere((k, v) => v == null);
  }
}
