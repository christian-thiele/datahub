import 'package:datahub/scaffold.dart';

sealed class const Config<T>._() {
  const factory(String path, {T? defaultValue, List<T>? values}) =
      PathConfig<T>._;

  const factory value(T value) = ValueConfig<T>._;

  T read() => Context.ofZone().read(this);
}

final class const PathConfig<T>._(
  final String path, {
  final T? defaultValue,
  final List<T>? values,
}) extends Config<T> {
  this : super._();
}

final class const ValueConfig<T>._(final T value) extends Config<T> {
  this : super._();
}
