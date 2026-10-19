import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';

class MissingIdFieldError(DataBean bean) extends ApiError {
  this : super('Data class "${bean.name}" does not provide an Id field.');
}
