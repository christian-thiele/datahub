import 'package:meta/meta_meta.dart';

import '../types/geometry/geometry.dart';

@Target({TargetKind.field})
abstract class DataFieldConstraint<FieldType> {
  final String _name;

  String get name => _name;

  const DataFieldConstraint({required String name}) : _name = name;

  bool check(FieldType value);
}

class MinLengthConstraint<FieldType extends String?>
    extends DataFieldConstraint<FieldType> {
  final int length;

  const MinLengthConstraint({
    required this.length,
    super.name = 'default.min-length',
  });

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

class MaxLengthConstraint<FieldType extends String?>
    extends DataFieldConstraint<FieldType> {
  final int length;

  const MaxLengthConstraint({
    required this.length,
    super.name = 'default.max-length',
  });

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

class RangeConstraint<FieldType extends num?>
    extends DataFieldConstraint<FieldType> {
  final num min;
  final num max;

  const RangeConstraint({
    required this.min,
    required this.max,
    super.name = 'default.range',
  });

  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return min <= value && value <= max;
  }
}

class RegExpConstraint<FieldType extends String?>
    extends DataFieldConstraint<FieldType> {
  final String expression;

  const RegExpConstraint({
    required this.expression,
    super.name = 'default.regexp',
  });

  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return RegExp(expression).hasMatch(value as String);
  }
}

class EnumConstraint<FieldType extends Enum?>
    extends DataFieldConstraint<FieldType> {
  final List<Enum> values;

  const EnumConstraint({required this.values, super.name = 'default.enum'});

  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return values.contains(value);
  }
}

class GeometryTypeConstraint<FieldType extends Geometry?>
    extends DataFieldConstraint<FieldType> {
  final GeometryType type;

  const GeometryTypeConstraint({
    required this.type,
    super.name = 'default.geometry-type',
  });

  @override
  bool check(FieldType value) {
    if (value == null) {
      return true;
    }

    return value.type == type;
  }
}

/// Applies [constraint] to every element of a list field.
class ElementConstraint<E> extends DataFieldConstraint<List<E>?> {
  final DataFieldConstraint<E> constraint;

  const ElementConstraint({required this.constraint})
    : super(name: 'default.element');

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
class MapValueConstraint<V> extends DataFieldConstraint<Map<dynamic, V>?> {
  final DataFieldConstraint<V> constraint;

  const MapValueConstraint({required this.constraint})
    : super(name: 'default.value');

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
