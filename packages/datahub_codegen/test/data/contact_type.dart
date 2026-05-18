import 'package:datahub/data.dart';

enum ContactType implements DataEnum {
  personal('personal-contact'),
  work('work-contact'),
  other('other');

  const ContactType(this.jsonValue);

  @override
  final String jsonValue;
}
