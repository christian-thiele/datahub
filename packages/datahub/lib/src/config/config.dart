import 'package:datahub/scaffold.dart';

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
