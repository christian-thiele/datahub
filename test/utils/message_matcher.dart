import 'package:test/test.dart';

class MessageMatcher extends CustomMatcher {
  MessageMatcher(messageMatcher)
      : super('with message that is', 'message', messageMatcher);

  @override
  Object? featureValueOf(actual) => (actual as dynamic).message;
}

Matcher throwsWith(String message) => throwsA(MessageMatcher(message));

Matcher throwsWithType<TException>(String message) =>
    throwsA(allOf(isA<TException>(), MessageMatcher(message)));
