import 'package:test/test.dart';

import 'matchers/response_body_matcher.dart';
import 'matchers/status_code_matcher.dart';

Matcher hasStatusCode(Matcher statusCodeMatcher) =>
    StatusCodeMatcher(statusCodeMatcher);

Matcher hasBody([Matcher? bodyMatcher]) =>
    ResponseBodyMatcher(bodyMatcher ?? isNotNull);

Matcher get isSuccess => hasStatusCode(inInclusiveRange(200, 299));
