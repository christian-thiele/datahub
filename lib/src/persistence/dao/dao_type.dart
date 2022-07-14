import 'package:datahub/transfer_object.dart';

/// Annotation for dao classes.
///
/// If name is not set, the name of the class is used.
class DaoType extends CopyWith {
  final String? name;
  const DaoType({this.name});
}
