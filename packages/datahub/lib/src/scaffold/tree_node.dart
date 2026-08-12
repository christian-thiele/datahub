import 'package:datahub/config.dart';

import 'service_host.dart';

sealed class TreeNode {
  TreeNode? _parent;

  TreeNode? get parent => _parent;
  final _children = <TreeNode>[];

  ConfigPath? _configPath;

  Iterable<TreeNode> get children => _children;

  TreeNode({List<TreeNode>? children}) {
    children?.forEach(add);
  }

  void add(TreeNode childNode) {
    childNode._parent = this;
    _children.add(childNode);
    childNode._invalidateConfigPath();
  }

  void remove(TreeNode childNode) {
    if (_children.remove(childNode)) {
      childNode._parent = null;
      childNode._invalidateConfigPath();
    }
  }

  /// The config path this node's [Config] values are resolved against.
  ///
  /// The result is cached, since it is read for every config value a service
  /// resolves. Re-parenting a node invalidates the cache of its whole subtree.
  ConfigPath getConfigPath() => _configPath ??= _buildConfigPath();

  ConfigPath _buildConfigPath() =>
      _parent?.getConfigPath() ?? ConfigPath.root();

  void _invalidateConfigPath() {
    _configPath = null;
    for (final child in _children) {
      child._invalidateConfigPath();
    }
  }
}

class ScopeTreeNode extends TreeNode {
  final Scope scope;

  ScopeTreeNode({required this.scope, super.children});

  @override
  ConfigPath _buildConfigPath() {
    if (scope.config case final config?) {
      return super._buildConfigPath().join(ConfigPath(config));
    } else {
      return super._buildConfigPath();
    }
  }
}

class ServiceTreeNode<T extends Service> extends TreeNode {
  final T service;
  ServiceInstance<T>? instance;

  ServiceTreeNode({required this.service, super.children, this.instance});
}
