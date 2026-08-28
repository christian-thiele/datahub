import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/src/scaffold/tree_node.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/test.dart';

/// A service that records the config values it resolved during initialization.
class ProbeService implements Service {
  final String label;
  final Config<String> host;
  final Config<int?> port;

  const ProbeService({
    required this.label,
    this.host = const Config('host'),
    this.port = const Config('port'),
  });

  @override
  ServiceInstance createInstance() => ProbeServiceInstance();
}

class ProbeServiceInstance extends ServiceInstance<ProbeService> {
  late final String host;
  late final int? port;

  String get label => service.label;

  @override
  Future<void> initialize() async {
    await super.initialize();
    host = read(service.host);
    port = read(service.port);
  }
}

/// Finds the probe carrying [label].
Find<ProbeServiceInstance> probe(String label) =>
    Find<ProbeServiceInstance>((p) => p.label == label);

void main() {
  // Scope(config:) prefixes every Config path below it. Nothing covered this
  // before, even though two separate mechanisms used to compute it.
  declareTest(
    'Scope: config prefix applies to services inside it',
    [
      Scope(
        config: 'db',
        components: [ProbeService(label: 'db')],
      ),
    ],
    () {
      final instance = probe('db').find();
      expect(instance.host, 'db.example.com');
      expect(instance.port, 5432);
    },
    config: const {
      'db': {'host': 'db.example.com', 'port': 5432},
      'host': 'wrong.example.com',
    },
  );

  declareTest(
    'Scope: nested config prefixes compose',
    [
      Scope(
        config: 'outer',
        components: [
          Scope(
            config: 'inner',
            components: [ProbeService(label: 'nested')],
          ),
        ],
      ),
    ],
    () {
      expect(probe('nested').find().host, 'nested.example.com');
    },
    config: const {
      'outer': {
        'inner': {'host': 'nested.example.com'},
        'host': 'wrong.example.com',
      },
      'host': 'wrong.example.com',
    },
  );

  declareTest(
    'Scope: a scope without config: adds no prefix',
    [
      Scope(
        components: [
          Scope(
            config: 'db',
            components: [
              Scope(components: [ProbeService(label: 'db')]),
            ],
          ),
        ],
      ),
    ],
    () {
      expect(probe('db').find().host, 'db.example.com');
    },
    config: const {
      'db': {'host': 'db.example.com'},
      'host': 'wrong.example.com',
    },
  );

  declareTest(
    'Scope: a dotted config prefix is expanded',
    [
      Scope(
        config: 'services.db',
        components: [ProbeService(label: 'db')],
      ),
    ],
    () {
      expect(probe('db').find().host, 'db.example.com');
    },
    config: const {
      'services': {
        'db': {'host': 'db.example.com'},
      },
    },
  );

  declareTest(
    'Scope: sibling scopes resolve independently',
    [
      Scope(
        config: 'primary',
        components: [ProbeService(label: 'primary')],
      ),
      Scope(
        config: 'replica',
        components: [ProbeService(label: 'replica')],
      ),
    ],
    () {
      expect(probe('primary').find().host, 'primary.example.com');
      expect(probe('replica').find().host, 'replica.example.com');
    },
    config: const {
      'primary': {'host': 'primary.example.com'},
      'replica': {'host': 'replica.example.com'},
    },
  );

  declareTest(
    'Scope: services outside any config scope read from the root',
    [ProbeService(label: 'root')],
    () {
      expect(probe('root').find().host, 'root.example.com');
    },
    config: const {'host': 'root.example.com'},
  );

  group('TreeNode - config path caching', () {
    ScopeTreeNode node(String? config) => ScopeTreeNode(
      scope: Scope(config: config, components: const []),
    );

    test('composes the path from the tree', () {
      final root = node('a');
      final child = node('b');
      final leaf = node(null);
      root.add(child);
      child.add(leaf);

      expect(root.getConfigPath().toString(), 'a');
      expect(child.getConfigPath().toString(), 'a.b');
      expect(leaf.getConfigPath().toString(), 'a.b');
    });

    test('repeated reads return an equal path', () {
      final root = node('a');
      final child = node('b');
      root.add(child);

      expect(child.getConfigPath(), child.getConfigPath());
      expect(child.getConfigPath().toString(), 'a.b');
    });

    test('re-parenting invalidates the cached path of the whole subtree', () {
      final oldParent = node('old');
      final newParent = node('new');
      final child = node('b');
      final leaf = node('c');

      child.add(leaf);
      oldParent.add(child);
      // Prime the cache before moving the subtree.
      expect(child.getConfigPath().toString(), 'old.b');
      expect(leaf.getConfigPath().toString(), 'old.b.c');

      oldParent.remove(child);
      newParent.add(child);

      expect(child.getConfigPath().toString(), 'new.b');
      expect(leaf.getConfigPath().toString(), 'new.b.c');
    });

    test('removing a node detaches it from its parent path', () {
      final parent = node('a');
      final child = node('b');
      parent.add(child);
      expect(child.getConfigPath().toString(), 'a.b');

      parent.remove(child);
      expect(child.getConfigPath().toString(), 'b');
      expect(parent.children, isEmpty);
    });

    test('removing a node that is not a child does nothing', () {
      final parent = node('a');
      final child = node('b');
      final stranger = node('c');
      parent.add(child);

      parent.remove(stranger);
      expect(parent.children, orderedEquals([child]));
      expect(child.getConfigPath().toString(), 'a.b');
    });
  });
}
