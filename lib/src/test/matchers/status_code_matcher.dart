import 'package:datahub/datahub.dart';
import 'package:test/expect.dart';

class StatusCodeMatcher extends Matcher {
  final Matcher statusCodeMatcher;

  StatusCodeMatcher(this.statusCodeMatcher);

  @override
  Description describe(Description description) => description
      .add('is response with status code ')
      .addDescriptionOf(statusCodeMatcher);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is RestResponse) {
      return statusCodeMatcher.matches(item.statusCode, matchState);
    } else if (item is ApiResponse) {
      return statusCodeMatcher.matches(item.statusCode, matchState);
    } else if (item is HttpResponse) {
      return statusCodeMatcher.matches(item.statusCode, matchState);
    }

    return false;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is RestResponse) {
      return mismatchDescription.add('has status code <${item.statusCode}>');
    } else if (item is ApiResponse) {
      return mismatchDescription.add('has status code <${item.statusCode}>');
    } else if (item is HttpResponse) {
      return mismatchDescription.add('has status code <${item.statusCode}>');
    } else {
      return mismatchDescription.add('is not a response type.');
    }
  }
}
