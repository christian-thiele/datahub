import 'package:collection/collection.dart';
import 'package:datahub/data.dart';

class DataObjectEquality implements Equality<Object?> {
  static const _fieldEquality = DeepCollectionEquality(
    DateTimeInstantEquality(),
  );

  const DataObjectEquality();

  @override
  bool equals(Object? e1, Object? e2) {
    if (e1 is DataObject) {
      if (e1.runtimeType != e2.runtimeType) {
        return false;
      }

      return e1.$$fields.every(
        (f) => _fieldEquality.equals(f.valueOf(e1), f.valueOf(e2)),
      );
    }

    return e1 == e2;
  }

  @override
  int hash(Object? e) {
    if (e is DataObject) {
      return Object.hashAll(
        e.$$fields.map((f) => _fieldEquality.hash(f.valueOf(e))),
      );
    }

    return e.hashCode;
  }

  @override
  bool isValidKey(Object? o) => true;
}

/// Compares [DateTime] values by instant, ignoring their time zone.
class DateTimeInstantEquality implements Equality<Object?> {
  const DateTimeInstantEquality();

  @override
  bool equals(Object? e1, Object? e2) {
    if (e1 is DateTime) {
      if (e2 is DateTime) {
        return e1.isAtSameMomentAs(e2);
      } else {
        return false;
      }
    }

    return e1 == e2;
  }

  @override
  int hash(Object? e) {
    if (e is DateTime) {
      return e.microsecondsSinceEpoch.hashCode;
    }
    return e.hashCode;
  }

  @override
  bool isValidKey(Object? o) => true;
}
