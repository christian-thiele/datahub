import 'dart:async';

import 'package:datahub/datahub.dart';

import 'service_registry.dart';
import 'tree_node.dart';

part 'component.dart';

part 'service.dart';

part 'scope.dart';

enum ServiceHostState {
  uninitialized,
  initializing,
  initialized,
  shutdown,
}

abstract class ServiceHost implements ServiceRegistry {
  TreeNode? _root;
  final _scopeKeys = <Object, TreeNode>{};
  ServiceHostState _state = ServiceHostState.uninitialized;

  ServiceHostState get state => _state;

  void Function(Service)? _registerHandler;

  Future<TreeNode> _initializeComponent(
    TreeNode? parent,
    Component component,
  ) async {
    switch (component) {
      case final Service service:
        final scopeKey = Object();
        final node = ServiceTreeNode(service: component);
        _scopeKeys[scopeKey] = node;
        parent?.add(node);

        final children = <Component>[];
        _registerHandler = children.add;

        try {
          final instance = service.createInstance();
          instance.service = service;
          instance.registry = this;
          instance._scopeKey = scopeKey;
          await instance.initialize();
          node.instance = instance;
        } catch (e, stack) {
          _onError('Could not initialize component.', e, stack);
          // TODO critical?
        }

        _registerHandler = null;

        for (final child in children) {
          await _initializeComponent(node, child);
        }
        return node;

      case final Scope scope:
        final node = ScopeTreeNode(scope: scope);
        parent?.add(node);
        for (final child in scope.components) {
          await _initializeComponent(node, child);
        }
        return node;
    }
  }

  Future<void> _shutdownComponent(TreeNode node) async {
    switch (node) {
      case ScopeTreeNode():
        break;
      case ServiceTreeNode<Service>():
        try {
          await node.instance?.dispose();
        } catch (e, stack) {
          _onError(
            'Could not shutdown component ${node.instance?.runtimeType}',
            e,
            stack,
          );
        }
    }

    for (final child in node.children) {
      await _shutdownComponent(child);
    }
  }

  Component buildRoot();

  Future<void> initialize() async {
    if (_root == null) {
      _state = ServiceHostState.initializing;
      _scopeKeys.clear();
      _root = await _initializeComponent(null, buildRoot());
      _state = ServiceHostState.initialized;
    } else {
      throw ApiException('ServiceHost already initialized.');
    }
  }

  Future<void> shutdown() async {
    if (_root case final root?) {
      _state = ServiceHostState.shutdown;
      await _shutdownComponent(root);
      _state = ServiceHostState.uninitialized;
    } else {
      throw ApiException('ServiceHost not initialized.');
    }
  }

  @override
  void register<T extends Service>(T service) {
    if (_registerHandler case final handler?) {
      handler(service);
    } else {
      throw Exception('Cannot register services at this time.');
    }
  }

  @override
  void deRegister<T extends Service>(ServiceInstance<T> instance) {
    void removeFrom(TreeNode node, ServiceInstance instance) {
      if (node case ServiceTreeNode(:final instance?)
          when instance == instance) {
        node.instance = null;
        return;
      }
      for (final child in node.children) {
        removeFrom(child, instance);
      }
    }

    if (_root case final root?) {
      removeFrom(root, instance);
    }
  }

  @override
  T find<T>(Find<T> finder, Object? scopeKey) {
    TreeNode? search(TreeNode node, Find<T> finder) {
      if (node case ServiceTreeNode(:final instance?)
          when finder.isCandidate(instance)) {
        return node;
      }

      for (final child in node.children) {
        if (search(child, finder) case final result?) {
          return result;
        }
      }

      return null;
    }

    TreeNode? peerSearch(TreeNode node, Find<T> finder) {
      if (node.parent case final parent?) {
        for (final child in parent.children) {
          if (child == node) continue;
          if (search(child, finder) case final result?) {
            return result;
          }
        }

        return peerSearch(parent, finder);
      }

      return null;
    }

    if (_scopeKeys[scopeKey] case final node?) {
      final resultNode = peerSearch(node, finder) ??
          (throw Exception('Could not find component with $finder.'));
      return (resultNode as ServiceTreeNode).instance as T;
    } else {
      throw Exception('Invalid scope key.');
    }
  }

  void _onError(String message, dynamic exception, StackTrace stack) {
    final buffer = StringBuffer();
    buffer.write(message);
    if (exception != null) {
      buffer.writeln();
      buffer.write(exception);
    }
    print(buffer);
    // TODO real log
  }
}
