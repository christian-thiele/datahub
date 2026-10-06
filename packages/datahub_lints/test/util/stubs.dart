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

sealed class Filter {
  static const Filter empty = EmptyFilter();
  static const Filter nothing = NothingFilter();

  const Filter();

  Filter and(Filter other) => throw '';

  Filter or(Filter other) => throw '';

  static Filter andGroup(Iterable<Filter> filters) => throw '';

  static Filter orGroup(Iterable<Filter> filters) => throw '';

  static Filter equals(dynamic left, dynamic right) => throw '';
}

final class FilterGroup extends Filter {
  final List<Filter> filters;
  final bool isConjunction;

  const FilterGroup(this.filters, this.isConjunction);
}

final class EmptyFilter extends Filter {
  const EmptyFilter();
}

final class NothingFilter extends Filter {
  const NothingFilter();
}

sealed class Sort {
  static const Sort empty = EmptySort();

  const Sort();

  static Sort asc(dynamic expression) => throw '';

  static Sort desc(dynamic expression) => throw '';

  static Sort followedBy(Iterable<Sort> sorts) => throw '';
}

final class SortGroup extends Sort {
  final List<Sort> sorts;

  const SortGroup(this.sorts);
}

final class EmptySort extends Sort {
  const EmptySort();
}

final class Data {
  const Data();
}

abstract mixin class DataObject<T> {}

final class DataBean<T> {
  const DataBean();
}

abstract class DataRepository<T> {}

final class RelationId<T> {
  const RelationId();
}

final class Id {
  final bool auto;

  const Id({this.auto = false});
}

typedef ScheduleCallback = Future<void> Function(Object run);

abstract class Schedule implements Service {
  const Schedule._();

  const factory Schedule.every(
    String name,
    ScheduleCallback run, {
    required Duration interval,
  }) = _Schedule.every;

  const factory Schedule.daily(
    String name,
    ScheduleCallback run, {
    int hour,
    int minute,
  }) = _Schedule.daily;

  const factory Schedule.monthly(
    String name,
    ScheduleCallback run, {
    int day,
    int hour,
    int minute,
  }) = _Schedule.monthly;
}

final class _Schedule extends Schedule {
  const _Schedule.every(
    String name,
    ScheduleCallback run, {
    required Duration interval,
  }) : super._();

  const _Schedule.daily(
    String name,
    ScheduleCallback run, {
    int hour = 0,
    int minute = 0,
  }) : super._();

  const _Schedule.monthly(
    String name,
    ScheduleCallback run, {
    int day = 1,
    int hour = 0,
    int minute = 0,
  }) : super._();

  @override
  ServiceInstance createInstance() => throw '';
}

abstract interface class WorkflowSignal<T> {}

sealed class WorkflowStep<T, TState extends Enum> {
  final TState? failureState;

  const WorkflowStep({String? name, this.failureState});
}

final class OnEnter<T, TState extends Enum> extends WorkflowStep<T, TState> {
  final TState state;
  final Duration after;
  final DateTime? Function(T element)? at;
  final Future<T> Function(T element) handle;

  const OnEnter(
    this.state,
    this.handle, {
    super.name,
    this.after = Duration.zero,
    this.at,
    super.failureState,
  });
}

final class OnSignal<T, TState extends Enum, TSignal>
    extends WorkflowStep<T, TState> {
  final DataBean<TSignal> signalBean;
  final List<TState> accept;
  final Object Function(TSignal signal) target;
  final Duration expireAfter;
  final Future<T> Function(T element, TSignal signal) handle;

  const OnSignal(
    this.signalBean, {
    required this.accept,
    required this.target,
    required this.handle,
    super.name,
    this.expireAfter = const Duration(days: 1),
    super.failureState,
  });
}

class WorkflowService<T, TState extends Enum> implements Service {
  final List<WorkflowStep<T, TState>> steps;

  const WorkflowService({required this.steps});

  @override
  ServiceInstance createInstance() => throw '';
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

/// Minimal stand-in for `package:datahub_aperture/datahub_aperture.dart`.
const apertureStub = r'''
import 'package:datahub/datahub.dart';

final class ApertureRelation<T> {
  const ApertureRelation();
}

class ApertureResource {
  final Find<DataRepository> repository;

  const ApertureResource({required this.repository});
}

class ApertureApi {
  final List<ApertureResource> resources;

  const ApertureApi({this.resources = const []});
}
''';

/// Minimal stand-in for `package:datahub_postgres/datahub_postgres.dart`.
const postgresStub = r'''
import 'package:datahub/datahub.dart';

class PostgresqlDataRepositoryService<T> implements Service {
  final DataBean<T> bean;

  const PostgresqlDataRepositoryService({required this.bean});

  @override
  ServiceInstance createInstance() => throw '';
}

class PostgresqlRevisableRepositoryService<T> implements Service {
  final DataBean<T> bean;

  const PostgresqlRevisableRepositoryService({required this.bean});

  @override
  ServiceInstance createInstance() => throw '';
}

mixin PostgresqlRevisableRepository<TService extends Service, TData>
    on ServiceInstance<TService> {}
''';
