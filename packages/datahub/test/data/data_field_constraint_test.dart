import 'package:datahub/data.dart';
import 'package:test/test.dart';

enum Status { open, closed }

enum Other { value }

/// Constraints are applied through [DataField.checkConstraints], which passes
/// the field value as `dynamic`, so a null value of a nullable field reaches
/// the constraint as well.
bool check(DataFieldConstraint constraint, dynamic value) =>
    constraint.check(value);

void main() {
  group('EnumConstraint', () {
    const constraint = EnumConstraint(values: Status.values);

    test('accepts a value of the enum', () {
      expect(check(constraint, Status.open), isTrue);
    });

    test('rejects a value of another enum', () {
      expect(check(constraint, Other.value), isFalse);
    });

    test('accepts null, so nullable fields may be empty', () {
      expect(check(constraint, null), isTrue);
    });
  });

  group('ElementConstraint', () {
    const constraint = ElementConstraint(
      constraint: MinLengthConstraint(length: 2),
    );

    test('accepts a list of accepted elements', () {
      expect(check(constraint, ['ab', 'abc']), isTrue);
    });

    test('rejects a list with a rejected element', () {
      expect(check(constraint, ['ab', 'a']), isFalse);
    });

    test('accepts an empty list', () {
      expect(check(constraint, <String>[]), isTrue);
    });

    test('accepts null, so nullable fields may be empty', () {
      expect(check(constraint, null), isTrue);
    });

    test('names itself after the element constraint', () {
      expect(constraint.name, 'default.element.default.min-length');
    });
  });

  group('MapValueConstraint', () {
    const constraint = MapValueConstraint(
      constraint: EnumConstraint(values: Status.values),
    );

    test('accepts a map of accepted values', () {
      expect(check(constraint, {'a': Status.open}), isTrue);
    });

    test('rejects a map with a rejected value', () {
      expect(check(constraint, {'a': Status.open, 'b': Other.value}), isFalse);
    });

    test('accepts an empty map', () {
      expect(check(constraint, <String, Status>{}), isTrue);
    });

    test('accepts null, so nullable fields may be empty', () {
      expect(check(constraint, null), isTrue);
    });

    test('names itself after the value constraint', () {
      expect(constraint.name, 'default.value.default.enum');
    });
  });
}
