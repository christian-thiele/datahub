import 'package:datahub/utils.dart';

class CodecException(super.message, final String? name) extends ApiException {
  factory typeMismatch(Type expected, Type actual, String? name) =
      TypeMismatchException.new;
}

class TypeMismatchException(
  final Type expected,
  final Type actual,
  String? name,
) extends CodecException {
  this
    : super(
        'Mismatching types${name == null ? '' : ' for property "$name"'}: Expected $expected but received $actual.',
        name,
      );
}
