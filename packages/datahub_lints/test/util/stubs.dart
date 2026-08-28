import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

/// Minimal stand-in for `package:datahub/datahub.dart`.
///
/// Only signatures matter for analysis, so bodies are omitted wherever the
/// language allows it and types are simplified where a rule does not look at
/// them.
const datahubStub = r'''
typedef Test<T> = bool Function(T);

bool always(Object? o) => true;

abstract interface class Component {}

abstract interface class Service implements Component {
  ServiceInstance createInstance();
}

abstract class ServiceInstance<TService extends Service> {
  late final TService service;
  late final Context context;

  Future<void> initialize() async {}

  Future<void> dispose() async {}

  T find<T>(Find<T> finder) => context.find<T>(finder);

  T read<T>(Config<T> config) => context.read<T>(config);
}

class Find<T> {
  final Test<T> test;

  const Find([this.test = always]);

  T find() => Context.ofZone().find(this);
}

final class Context {
  static Context ofZone() => throw '';

  static Context? maybeOfZone() => throw '';

  static T zoneFind<T>(Find<T> finder) => Context.ofZone().find<T>(finder);

  static T zoneRead<T>(Config<T> config) => Context.ofZone().read<T>(config);

  T find<T>(Find<T> finder) => throw '';

  T read<T>(Config<T> config) => throw '';
}

sealed class Config<T> {
  const Config._();

  const factory Config(String path, {T? defaultValue, List<T>? values}) =
      PathConfig<T>._;

  const factory Config.value(T value) = ValueConfig<T>._;

  T read() => Context.ofZone().read(this);
}

final class PathConfig<T> extends Config<T> {
  final String path;
  final T? defaultValue;
  final List<T>? values;

  const PathConfig._(this.path, {this.defaultValue, this.values}) : super._();
}

final class ValueConfig<T> extends Config<T> {
  final T value;

  const ValueConfig._(this.value) : super._();
}

abstract class ApiNode {
  const ApiNode();

  List<Object> buildRoutes();
}

final class Data {
  const Data();
}

abstract mixin class DataObject<T> {}

final class DataBean<T> {
  const DataBean();
}

final class RelationId<T> {
  const RelationId();
}
''';

/// Adds the `package:datahub/datahub.dart` stub to the test workspace.
///
/// Must be called from `setUp`, before `super.setUp()`.
void addDatahubStub(AnalysisRuleTest test) {
  test.newPackage('datahub').addFile('lib/datahub.dart', datahubStub);
}

/// Locates the first occurrence of [snippet] in [content].
///
/// Rule tests express expected diagnostics as source snippets rather than
/// hand-counted offsets, so that edits to the sample code do not silently
/// shift every expectation.
int offsetOf(String content, String snippet) {
  final offset = content.indexOf(snippet);
  if (offset < 0) {
    throw ArgumentError.value(snippet, 'snippet', 'Not found in the source');
  }
  return offset;
}

/// Minimal stand-in for `package:datahub_postgres/datahub_postgres.dart`.
const postgresStub = r'''
import 'package:datahub/datahub.dart';

abstract interface class Postgresql {}

mixin PostgresqlDataRepository<TService extends Service, TData>
    on ServiceInstance<TService> {
  late final Object dataRelation;

  @override
  Future<void> initialize() async {}
}

mixin DatabaseConnectionManager<TService extends Service, TConnection>
    on ServiceInstance<TService> {
  @override
  Future<void> initialize() async {}
}
''';

/// Minimal stand-in for `package:datahub_aperture/datahub_aperture.dart`.
const apertureStub = r'''
final class ApertureRelation<T> {
  const ApertureRelation();
}
''';
