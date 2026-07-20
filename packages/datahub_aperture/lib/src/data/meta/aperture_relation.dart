import 'package:datahub/data.dart';
import 'package:boost/boost.dart';
import 'package:meta/meta_meta.dart';

/// Annotation for DataObjects declaring a related resource
@Target({TargetKind.classType})
final class ApertureRelation<T> extends MetaData {
  TypeCheck<T> get type => TypeCheck<T>();
  const ApertureRelation();
}
