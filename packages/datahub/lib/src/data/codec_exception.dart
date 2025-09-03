import 'package:datahub/utils.dart';

class CodecException extends ApiException {
  final String? name;

  CodecException(super.message, this.name);

  factory CodecException.typeMismatch(
      Type expected, Type actual, String? name) = TypeMismatchException.new;
}

class TypeMismatchException extends CodecException {
  final Type expected;
  final Type actual;

  TypeMismatchException(this.expected, this.actual, String? name)
      : super(
          'Mismatching types${name == null ? '' : ' for property "$name"'}: Expected $expected but received $actual.',
          name,
        );
}
