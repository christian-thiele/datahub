import 'package:datahub/persistence.dart';

import 'postgresql_data_types.dart';

abstract class TypeRegistry {
  PostgresqlDataType findType(DataField field);
}
