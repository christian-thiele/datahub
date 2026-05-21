import 'package:meta/meta_meta.dart';

import 'meta_data.dart';

@Target({TargetKind.field})
final class Id extends MetaData {
  final bool auto;

  const Id({this.auto = false});
}
