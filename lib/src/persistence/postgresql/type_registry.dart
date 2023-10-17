import 'package:datahub/persistence.dart';

import 'postgresql_data_types.dart';

abstract class TypeRegistry {
  PostgresqlDataType findType<T, TDataType extends DataType<T>>(
      DataType<T> dataType);
}
