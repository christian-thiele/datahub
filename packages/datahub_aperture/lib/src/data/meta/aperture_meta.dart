import 'package:datahub/data.dart';
import 'package:meta/meta_meta.dart';

/// Annotation for DataObjects adding meta info to a resource
@Target({TargetKind.classType})
final class ApertureMeta extends MetaData {
  final String? titleTemplate;

  const ApertureMeta({this.titleTemplate});
}
