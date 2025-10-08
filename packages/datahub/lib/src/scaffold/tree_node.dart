import 'package:datahub/config.dart';

import 'service_host.dart';

sealed class TreeNode {
  TreeNode? _parent;

  TreeNode? get parent => _parent;
  final _children = <TreeNode>[];

  Iterable<TreeNode> get children => _children;

  TreeNode({List<TreeNode>? children}) {
    children?.forEach(add);
  }

  void add(TreeNode childNode) {
    childNode._parent = this;
    _children.add(childNode);
  }

  void remove(TreeNode childNode) {
    if (_children.contains(childNode)) {
      childNode._parent = null;
      _children.remove(childNode);
    }
  }

  ConfigPath getConfigPath() => _parent?.getConfigPath() ?? ConfigPath.root();
}

class ScopeTreeNode extends TreeNode {
  final Scope scope;

  ScopeTreeNode({required this.scope, super.children});

  @override
  ConfigPath getConfigPath() {
    if (scope.config case final config?) {
      return super.getConfigPath().join(ConfigPath(config));
    } else {
      return super.getConfigPath();
    }
  }
}

class ServiceTreeNode<T extends Service> extends TreeNode {
  final T service;
  ServiceInstance<T>? instance;

  ServiceTreeNode({required this.service, super.children, this.instance});
}
