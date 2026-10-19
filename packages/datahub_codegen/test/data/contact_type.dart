import 'package:datahub/data.dart';

enum ContactType(@override final String jsonValue) implements DataEnum {
  personal('personal-contact'),
  work('work-contact'),
  other('other'),
}
