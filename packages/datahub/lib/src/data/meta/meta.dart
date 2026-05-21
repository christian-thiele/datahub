import 'package:meta/meta_meta.dart';

import 'meta_data.dart';

/// Annotation for providing meta information to a [DataObject] class or fields.
@Target({TargetKind.classType, TargetKind.field})
final class Meta extends MetaData {
  final String? name;
  final String? namePlural;
  final String? description;
  final int? icon;

  const Meta({this.name, this.namePlural, this.description, this.icon});
}
