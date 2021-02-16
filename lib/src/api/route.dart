import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/api_error.dart';

// placeholder detector regex
final RegExp _plExp = RegExp('(?<!\\\\){([\\w-]*)}');

// route pattern validation regex
final RegExp _vrExp =
    RegExp('^(\\/([\\w\\.-]*((?<!\\\\){([a-zA-Z0-9]*)})?))*(\\/\\*?)?\$');

const _wildcardGroup = 'route_wildcard';

/// Represents a route pattern against which request paths will be matched.
///
/// [RoutePattern]s are defined using a specific syntax. They can contain
/// placeholders for parts of the route which can be read by the endpoint.
/// Invalid route patterns will throw an [ApiError].
///
/// *Examples:*
/// `/path/to/endpoint`
/// `/users/joe`
///
/// __Placeholders:__
///
/// Placeholders can be used to create a dynamic route pattern. In this example
/// we create the pattern for a user endpoint:
///
/// *Examples:*
/// `/users/{name}`
/// `/users/{name}/pictures`
/// `/texts/article_{article_id}`
///
/// *The placeholder `{name}` will allow anything as long as it is a single
/// path segment.*
///
/// For the route pattern
/// `/users/{name}/pictures`
/// the following path will match:
/// `/users/joe/pictures`
/// and the following will not:
/// `/users/pictures`
/// `/users/two/segments/pictures`
///
/// Multiple Placeholders can be used in a single route and placeholders
/// can also have a prefix:
/// `/category/{category_name}/article_{article_id}`
///
/// Against the example pattern above following routes will match:
/// `/category/fiction/article_2354`
/// `/category/science/article_abc`
/// while the following will not:
/// `/category/article_2354`
/// `/category/science/article_`
///
/// __Wildcard-Suffix__
///
/// All of the examples above are closed routes, which means that they have
/// to match in full length with the path to match at all.
///
/// Example route:
/// `/path/{x}/something`
/// This path will match:
/// `/path/to/something`
/// This one will not:
/// `/path/to/something/else`
///
/// If sub-paths are required to match the pattern also, a wildcard suffix can
/// be used. *Wildcard suffix only work at the end of the pattern!*
///
/// Example route:
/// `/path/{x}/something/*`
/// This paths will match:
/// `/path/to/something`
/// `/path/to/something/else`
/// `/path/to/something/else/and/more`
///
/// The segments matched by the wildcard-suffix is also stored in the [Route]
/// object. See [Route.wildcard]
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

  /// Encodes url params into a path.
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

  /// Decodes a path using the route pattern.
  ///
  /// Path parameters will be stored in the returned [Route] object.
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

/// Represents a path which has been matched with a [RoutePattern].
///
/// Route provides the [RoutePattern] with which the path has been matched
/// and all route parameters defined by the [RoutePattern].
/// If the pattern uses a wildcard suffix, the wildcard-part of the path
/// is stored in [Route.wildcard].
class Route {
  final RoutePattern pattern;
  final Map<String, String> routeParams;
  final String? wildcard;

  Route(this.pattern, this.routeParams, this.wildcard);
}
