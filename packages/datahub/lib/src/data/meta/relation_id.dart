import 'package:boost/boost.dart';
import 'package:meta/meta_meta.dart';

import 'meta_data.dart';

@Target({TargetKind.field})
final class RelationId<T> extends MetaData {
  TypeCheck<T> get type => TypeCheck<T>();

  const RelationId();
}
