import 'package:datahub/data.dart';
import 'package:meta/meta_meta.dart';

/// Annotation for DataObject fields
@Target({TargetKind.field})
final class const ApertureField({
  final bool isDisplayField = false,
  final bool readOnly = false,
  final bool allowFilter = true,
  final bool allowSearch = true,
  final bool allowSort = true,
}) extends MetaData;
