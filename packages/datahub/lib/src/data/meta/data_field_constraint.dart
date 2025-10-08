abstract class DataFieldConstraint<FieldType> {
  final String name;

  const DataFieldConstraint({required this.name});

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
  bool check(FieldType value) => values.contains(value);
}
