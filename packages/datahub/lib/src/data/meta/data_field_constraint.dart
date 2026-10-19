import 'package:meta/meta_meta.dart';

import '../types/geometry/geometry.dart';

@Target({TargetKind.field})
abstract class const DataFieldConstraint<FieldType>({
  required final String _name,
}) {
  String get name => _name;

  bool check(FieldType value);
}

class const MinLengthConstraint<FieldType extends String?>({
  required final int length,
  super.name = 'default.min-length',
}) extends DataFieldConstraint<FieldType> {
  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return value.length >= length;
  }

  @override
  String toString() => 'Text length must be >= $length';
}

class const MaxLengthConstraint<FieldType extends String?>({
  required final int length,
  super.name = 'default.max-length',
}) extends DataFieldConstraint<FieldType> {
  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return value.length <= length;
  }

  @override
  String toString() => 'Text length must be <= $length';
}

class const RangeConstraint<FieldType extends num?>({
  required final num min,
  required final num max,
  super.name = 'default.range',
}) extends DataFieldConstraint<FieldType> {
  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return min <= value && value <= max;
  }
}

class const RegExpConstraint<FieldType extends String?>({
  required final String expression,
  super.name = 'default.regexp',
}) extends DataFieldConstraint<FieldType> {
  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return RegExp(expression).hasMatch(value as String);
  }
}

class const EnumConstraint<FieldType extends Enum?>({
  required final List<Enum> values,
  super.name = 'default.enum',
}) extends DataFieldConstraint<FieldType> {
  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return values.contains(value);
  }
}

class const GeometryTypeConstraint<FieldType extends Geometry?>({
  required final GeometryType type,
  super.name = 'default.geometry-type',
}) extends DataFieldConstraint<FieldType> {
  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return value.type == type;
  }
}

/// Applies [constraint] to every element of a list field.
class const ElementConstraint<E>({
  required final DataFieldConstraint<E> constraint,
}) extends DataFieldConstraint<List<E>?> {
  this : super(name: 'default.element');

  @override
  String get name => 'default.element.${constraint.name}';

  @override
  bool check(List<E>? value) {
    if (value == null) {
      return true;
    }

    for (final element in value) {
      if (!constraint.check(element)) {
        return false;
      }
    }

    return true;
  }
}

/// Applies [constraint] to every value of a map field.
class const MapValueConstraint<V>({
  required final DataFieldConstraint<V> constraint,
}) extends DataFieldConstraint<Map<dynamic, V>?> {
  this : super(name: 'default.value');

  @override
  String get name => 'default.value.${constraint.name}';

  @override
  bool check(Map<dynamic, V>? value) {
    if (value == null) {
      return true;
    }

    for (final element in value.values) {
      if (!constraint.check(element)) {
        return false;
      }
    }

    return true;
  }
}
