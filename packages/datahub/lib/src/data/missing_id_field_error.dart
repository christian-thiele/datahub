import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';

class MissingIdFieldError extends ApiError {
  MissingIdFieldError(DataBean bean)
    : super('Data class "${bean.name}" does not provide an Id field.');
}
