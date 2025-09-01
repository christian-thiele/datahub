import 'package:boost/boost.dart';

import 'meta_data.dart';

final class RelationId<T> extends MetaData {
  TypeCheck<T> get type => TypeCheck<T>();
  const RelationId();
}
