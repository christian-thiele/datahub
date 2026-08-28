import 'dart:convert';
import 'dart:io';

import 'package:datahub/api.dart';
import 'package:datahub/utils.dart';

import 'service_host.dart';
import 'tree_node.dart';

/// Describe mode replaces the normal application run when the
/// `DATAHUB_DESCRIBE` environment variable is set.
///
/// Instead of initializing services, the component tree is built
/// structurally (no sockets, no database connections) and a description
/// document (currently only the `openapi` target) is generated from all
/// [ApiService] components and written to `DATAHUB_DESCRIBE_OUT` (or stdout
/// between sentinel lines if unset).
///
/// Route construction ([ApiNode.buildRoutes]) runs inside a context bound
/// to the ApiService's position in the tree, so configuration reads resolve
/// normally (including values passed via `-c`/`-f` arguments). Service
/// lookups are not available during describe mode; route construction must
/// depend only on configuration.
final class DescribeMode {
  static const targetOpenApi = 'openapi';

  static const stdoutBeginSentinel = '---DATAHUB-DESCRIBE-BEGIN---';
  static const stdoutEndSentinel = '---DATAHUB-DESCRIBE-END---';

  final String target;
  final String? outPath;
  final String? title;
  final String? version;

  /// Non-fatal problems encountered during the last [describe] call.
  final List<String> warnings = [];

  DescribeMode({required this.target, this.outPath, this.title, this.version});

  /// Creates a [DescribeMode] from the process environment, or null if
  /// `DATAHUB_DESCRIBE` is not set.
  static DescribeMode? fromEnvironment([Map<String, String>? environment]) {
    final env = environment ?? Platform.environment;
    if (env['DATAHUB_DESCRIBE'] case final target? when target.isNotEmpty) {
      return DescribeMode(
        target: target,
        outPath: env['DATAHUB_DESCRIBE_OUT'],
        title: env['DATAHUB_DESCRIBE_TITLE'],
        version: env['DATAHUB_DESCRIBE_VERSION'],
      );
    }
    return null;
  }

  /// Builds the description document for [host] without initializing it.
  Map<String, dynamic> describe(ServiceHost host) {
    if (target != targetOpenApi) {
      throw ApiError('Unknown describe target: $target');
    }

    warnings.clear();

    final root = _buildStructure(host.buildRoot());
    final apiServices = _collectApiServices(root).toList();
    if (apiServices.isEmpty) {
      throw ApiError('No ApiService found in the component tree.');
    }

    final builder = OpenApiBuilder(
      title: title ?? 'API',
      version: version ?? '1.0.0',
    );

    Map<String, dynamic>? document;
    for (final node in apiServices) {
      final routes = (node.service as ApiService).routes;
      final part = host.runInScope(node, () => builder.build(routes));
      warnings.addAll(builder.warnings);
      document = document == null ? part : _merge(document, part);
    }

    return document!;
  }

  /// Builds the document and writes it to [outPath] or stdout.
  Future<void> execute(ServiceHost host) async {
    final document = describe(host);
    final json = const JsonEncoder.withIndent('  ').convert(document);

    for (final warning in warnings) {
      stderr.writeln('Warning: $warning');
    }

    if (outPath case final path?) {
      await File(path).writeAsString(json);
    } else {
      stdout.writeln(stdoutBeginSentinel);
      stdout.writeln(json);
      stdout.writeln(stdoutEndSentinel);
    }
  }

  TreeNode _buildStructure(Component component) {
    switch (component) {
      case final Service service:
        return ServiceTreeNode(service: service);
      case final Scope scope:
        final node = ScopeTreeNode(scope: scope);
        for (final child in scope.components) {
          node.add(_buildStructure(child));
        }
        return node;
    }
  }

  Iterable<ServiceTreeNode> _collectApiServices(TreeNode node) sync* {
    if (node case ServiceTreeNode(service: ApiService())) {
      yield node;
    }
    for (final child in node.children) {
      yield* _collectApiServices(child);
    }
  }

  Map<String, dynamic> _merge(
    Map<String, dynamic> target,
    Map<String, dynamic> other,
  ) {
    final targetComponents = target['components'] as Map<String, dynamic>;
    final otherComponents = other['components'] as Map<String, dynamic>;
    return {
      ...target,
      'paths': {
        ...target['paths'] as Map<String, dynamic>,
        ...other['paths'] as Map<String, dynamic>,
      },
      'components': {
        'schemas': {
          ...targetComponents['schemas'] as Map<String, dynamic>,
          ...otherComponents['schemas'] as Map<String, dynamic>,
        },
        if (targetComponents.containsKey('securitySchemes') ||
            otherComponents.containsKey('securitySchemes'))
          'securitySchemes': {
            ...?targetComponents['securitySchemes'] as Map<String, dynamic>?,
            ...?otherComponents['securitySchemes'] as Map<String, dynamic>?,
          },
      },
    };
  }
}
