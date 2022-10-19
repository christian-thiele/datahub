import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

class ResponseBodyMatcher extends Matcher {
  final Matcher responseBodyMatcher;

  ResponseBodyMatcher(this.responseBodyMatcher);

  @override
  Description describe(Description description) => description
      .add('is response with body ')
      .addDescriptionOf(responseBodyMatcher);

  @override
  bool matches(dynamic item, Map matchState) {
    return item is RestResponse &&
        responseBodyMatcher.matches(
            item.hasData ? item.data : null, matchState);
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is RestResponse) {
      return responseBodyMatcher.describeMismatch(
        item.hasData ? item.data : null,
        mismatchDescription
            .add('has body <${item.hasData ? item.data : null}>\n'),
        matchState,
        verbose,
      );
    } else {
      return mismatchDescription.add('is not a response type.');
    }
  }
}
