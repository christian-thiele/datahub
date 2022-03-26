import 'package:cl_datahub/cl_datahub.dart';

/// Annotation for dao classes.
///
/// If name is not set, the name of the class is used.
class DaoType extends CopyWith {
  final String? name;
  const DaoType({this.name});
}
