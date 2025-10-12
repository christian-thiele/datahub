import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';

import 'data_field.dart';

abstract mixin class DataObject<T> {
  String get $$name;

  List<DataField<T, dynamic>> get $$fields;

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final results = $$fields.map((f) {
      final thisValue = f.valueOf(this as T);
      final otherValue = f.valueOf(other as T);
      if (thisValue == otherValue) {
        return true;
      }

      if (thisValue == null || otherValue == null) {
        return false;
      }

      if (f is DataField<T, List?>) {
        return (thisValue as List).sequenceEquals(otherValue);
      } else if (f is DataField<T, Map?>) {
        return (thisValue as Map).entriesEqual(otherValue);
      } else if (f is DataField<T, DateTime?>) {
        return (thisValue as DateTime).isAtSameMomentAs(otherValue);
      }

      return false;
    }).toList();

    return results.every((e) => e);
  }

  @override
  int get hashCode => Object.hashAll($$fields.map((f) => f.valueOf(this as T)));
}
