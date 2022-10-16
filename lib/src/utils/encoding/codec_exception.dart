import 'package:datahub/utils.dart';

class CodecException extends ApiException {
  CodecException(super.message);

  CodecException.typeMismatch(Type expected, Type actual)
      : super('Mismatching types: Expected $expected but received $actual.');
}
