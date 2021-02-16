import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/api_error.dart';

// placeholder detector regex
final RegExp _plExp = RegExp('(?<!\\\\){([\\w-]*)}');

// route pattern validation regex
final RegExp _vrExp =
    RegExp('^(\\/([\\w\\.-]*((?<!\\\\){([a-zA-Z0-9]*)})?))*(\\/\\*?)?\$');

const _wildcardGroup = 'route_wildcard';

class RoutePattern {
  final String pattern;
  final RegExp routeMatchExp;
  final bool isWildcardPattern;

  RoutePattern._(this.pattern, this.routeMatchExp, this.isWildcardPattern);

  factory RoutePattern(String pattern) {
    const wildcardSuffix = '(?<$_wildcardGroup>(\\/([\\w\\.-]*))*)';

    if (pattern.endsWith('/')) {
      pattern = pattern.substring(0, pattern.length - 1);
    }

    if (!_vrExp.hasMatch(pattern)) {
      throw ApiError('Invalid route pattern: $pattern');
    }

    final isWildcard = pattern.endsWith('/*') || pattern.endsWith('/*/');

    final buffer = StringBuffer('^');
    buffer.write(pattern
        .replaceAll('/', '\\/')
        .replaceAll('.', '\\.')
        .replaceAllMapped(_plExp, (match) {
      final key = match.group(1);
      return '(?<$key>[\\w\\-\\.]+)';
    }));

    if (isWildcard) {
      buffer.write(wildcardSuffix);
    }

    buffer.write('\\/?\$');

    final regex = RegExp(buffer.toString(), caseSensitive: false);
    return RoutePattern._(pattern, regex, isWildcard);
  }

  String encode(Map<String, dynamic> values) {
    //TODO add encode method for values, not just toString
    return pattern.replaceAllMapped(_plExp, (match) {
      final key = match.group(1);
      if (key == null) {
        throw ApiException('Invalid placeholder-key: ${match.group(0)}');
      }

      if (values[key] == null) {
        throw ApiException('Missing value in url params: $key');
      }

      return Uri.encodeComponent(values[key].toString());
    });
  }

  Route decode(String path) {
    final match = routeMatchExp.firstMatch(path);
    if (match == null) {
      throw ApiException('Could not match pattern.');
    }

    final pathParams = Map.fromEntries(match.groupNames
        .where((e) => e != _wildcardGroup)
        .map((e) => MapEntry(e, match.namedGroup(e)!)));

    final wildcard = match.groupNames.contains(_wildcardGroup)
        ? match.namedGroup(_wildcardGroup)
        : null;

    return Route(this, pathParams, wildcard);
  }

  bool match(String path) => routeMatchExp.hasMatch(path);
}

class Route {
  final RoutePattern pattern;
  final Map<String, String> routeParams;
  final String? wildcard;

  Route(this.pattern, this.routeParams, this.wildcard);
}
