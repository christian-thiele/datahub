import 'package:datahub/utils.dart';

class CodecException extends ApiException {
  CodecException(super.message);

  CodecException.typeMismatch(Type expected, Type actual, String? name)
      : super(
            'Mismatching types${name == null ? '' : ' for property "$name"'}: Expected $expected but received $actual.');
}
