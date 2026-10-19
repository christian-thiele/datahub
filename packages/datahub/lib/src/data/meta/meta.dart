import 'package:meta/meta_meta.dart';

import 'meta_data.dart';

/// Annotation for providing meta information to a [DataObject] class or fields.
@Target({TargetKind.classType, TargetKind.field})
final class const Meta({
  final String? name,
  final String? namePlural,
  final String? description,
  final int? icon,
}) extends MetaData;
