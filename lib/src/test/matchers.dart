import 'package:test/test.dart';

import 'matchers/status_code_matcher.dart';

Matcher hasStatusCode(Matcher statusCodeMatcher) =>
    StatusCodeMatcher(statusCodeMatcher);

Matcher get isSuccess => hasStatusCode(inInclusiveRange(200, 299));
