import 'package:datahub/data.dart';

import 'data_field.dart';
import 'equality.dart';

abstract mixin class DataObject<T> {
  String get $$name;

  List<DataField<T, dynamic>> get $$fields;

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      const DataObjectEquality().equals(this, other);

  @override
  int get hashCode => const DataObjectEquality().hash(this);
}
