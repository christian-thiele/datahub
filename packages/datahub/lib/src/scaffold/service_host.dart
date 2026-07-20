import 'dart:async';

import 'package:datahub/config.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';
import 'package:meta/meta.dart';

import 'service_registry.dart';
import 'tree_node.dart';

part 'component.dart';
part 'context.dart';
part 'find.dart';
part 'scope.dart';
part 'service.dart';

enum ServiceHostState { uninitialized, initializing, initialized, shutdown }

abstract class ServiceHost implements ServiceRegistry {
  final _postInitializationCallbacks = <(FutureOr<void> Function(), Context)>[];
  final configuration = Configuration();

  TreeNode? _root;

  ServiceHostState _state = ServiceHostState.uninitialized;

  ServiceHostState get state => _state;

  void Function(Service)? _registerHandler;

  Future<TreeNode> _initializeComponent(
    TreeNode? parent,
    Component component,
    ConfigPath configScope,
  ) async {
    switch (component) {
      case final Service service:
        final node = ServiceTreeNode(service: component);
        parent?.add(node);

        final context = Context._(
          environment: configuration.environment,
          registry: this,
          scope: node,
          sessions: [],
          debugName: '${component.runtimeType}#${component.hashCode}',
        );

        final children = <Component>[];
        _registerHandler = children.add;

        try {
          final instance = service.createInstance();
          instance.service = service;
          instance.registry = this;
          instance.context = context;

          await context.run(() async {
            await instance.initialize();
          });

          node.instance = instance;
        } catch (e, stack) {
          log.fatal(
            'Could not initialize component ${service.runtimeType}.',
            error: e,
            stack: stack,
          );
          rethrow;
        }

        _registerHandler = null;

        for (final child in children) {
          await _initializeComponent(node, child, configScope);
        }

        return node;

      case final Scope scope:
        final node = ScopeTreeNode(scope: scope);
        parent?.add(node);

        final childConfigScope = scope.config != null
            ? configScope[scope.config!]
            : configScope;

        final context = Context._(
          environment: configuration.environment,
          registry: this,
          scope: node,
          sessions: [],
          debugName: '${component.runtimeType}#${component.hashCode}',
        );

        await context.run(() async {
          for (final child in scope.components) {
            await _initializeComponent(node, child, childConfigScope);
          }
        });
        return node;
    }
  }

  Future<void> _runPostInitializationCallbacks() async {
    while (_postInitializationCallbacks.isNotEmpty) {
      final callback = _postInitializationCallbacks.removeAt(0);
      callback.$2.run(() async {
        try {
          await callback.$1();
        } catch (e, stack) {
          log.error(
            'Post initialization hook threw exception.',
            error: e,
            stack: stack,
          );
        }
      });
    }
  }

  Future<void> _shutdownComponent(TreeNode node) async {
    for (final child in node.children.toList().reversed) {
      await _shutdownComponent(child);
    }

    switch (node) {
      case ScopeTreeNode():
        break;
      case ServiceTreeNode<Service>():
        try {
          await node.instance?.context.run(() async {
            await node.instance?.dispose();
          });
        } catch (e, stack) {
          log.error(
            'Could not shutdown component ${node.instance?.runtimeType}',
            error: e,
            stack: stack,
          );
        }
    }
  }

  Component buildRoot();

  Future<void> initialize() async {
    if (_root == null) {
      _state = ServiceHostState.initializing;
      _root = await _initializeComponent(null, buildRoot(), ConfigPath.root());
      _state = ServiceHostState.initialized;
      _runPostInitializationCallbacks();
    } else {
      throw ApiException('ServiceHost already initialized.');
    }
  }

  Future<void> shutdown() async {
    if (_root case final root?) {
      _state = ServiceHostState.shutdown;
      await _shutdownComponent(root);
      _root = null;
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
  void registerPostInitializationCallback(FutureOr<void> Function() callback) {
    if (state != ServiceHostState.initializing) {
      throw ApiError(
        'Post initialization callbacks can only be registered inside a services initialize() method.',
      );
    }

    _postInitializationCallbacks.add((callback, Context.ofZone()));
  }

  /*
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
  }*/

  @override
  T findComponent<T>(Find<T> finder, TreeNode? scope) {
    TreeNode? search(TreeNode node, Find<T> finder) {
      if (node case ServiceTreeNode(
        :final instance?,
      ) when finder.isCandidate(instance)) {
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

    if (scope == null && _root != null) {
      final resultNode = search(_root!, finder);
      if (resultNode == null) {
        if (null is T) {
          return null as T;
        } else {
          throw ApiException('Could not find component with $finder.');
        }
      }
      return (resultNode as ServiceTreeNode).instance as T;
    } else if (scope case final node?) {
      final resultNode = peerSearch(node, finder);
      if (resultNode == null) {
        if (null is T) {
          return null as T;
        } else {
          throw ApiException('Could not find component with $finder.');
        }
      }
      return (resultNode as ServiceTreeNode).instance as T;
    } else {
      if (null is T) {
        return null as T;
      } else {
        throw ApiException('Component tree not initialized.');
      }
    }
  }

  @override
  T readConfig<T>(Config<T> config, TreeNode scope) {
    final scopePath = scope.getConfigPath();
    return switch (config) {
      PathConfig<Enum?>(
        :final path,
        :final T defaultValue?,
        :final List<T> values?,
      ) =>
        configuration.readEnum<T?>(scopePath.join(ConfigPath(path)), values) ??
            defaultValue,
      PathConfig<Enum?>(:final path, :final List<T> values?) =>
        configuration.readEnum<T>(scopePath.join(ConfigPath(path)), values),
      PathConfig<T>(:final path, :final defaultValue?) =>
        configuration.read<T?>(scopePath.join(ConfigPath(path))) ??
            defaultValue,
      PathConfig<T>(:final path) => configuration.read<T>(
        scopePath.join(ConfigPath(path)),
      ),
      ValueConfig<T>(:final value) => value,
    };
  }
}
