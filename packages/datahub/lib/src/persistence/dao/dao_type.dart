import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

/// Annotation for dao classes.
///
/// If name is not set, the name of the class is used.
class DaoType extends CopyWith {
  final String? name;
  final NamingConvention namingConvention;

  const DaoType({
    this.name,
    this.namingConvention = NamingConvention.lowerSnakeCase,
  });
}
