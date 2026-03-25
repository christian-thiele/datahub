import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class DocsSidebar extends StatelessComponent {
  final Page page;

  const DocsSidebar({required this.page});

  @override
  Component build(BuildContext context) {
    final pages = context.pages;
    final navigationTree = _buildNavigationTree(pages);

    return aside(
      classes:
          'w-72 hidden lg:block fixed left-0 top-16 bottom-0 bg-surface-container-low overflow-y-auto px-6 py-12 scrollbar-hide',
      [
        div(classes: 'relative mb-10 group', [
          input(
            classes:
                'w-full bg-surface-container-highest border-none text-sm px-10 py-3 rounded-md focus:ring-1 focus:ring-primary focus:bg-surface-container transition-all placeholder:text-on-surface-variant/50',
            attributes: {'placeholder': 'Search documentation...'},
            type: InputType.text,
          ),
          span(
            classes:
                'material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant text-sm',
            [Component.text('search')],
          ),
          span(
            classes:
                'absolute right-3 top-1/2 -translate-y-1/2 text-[10px] text-on-surface-variant border border-outline-variant px-1 rounded',
            [Component.text('⌘K')],
          ),
        ]),
        nav(
          classes: 'space-y-8',
          navigationTree.map((section) {
            return _SidebarSection(
              title: section.title,
              items: [
                _SidebarItem(
                  text: 'Overview',
                  href: section.path,
                  isActive: page.url == section.path,
                ),
                ...section.children.map((item) {
                  return _SidebarItem(
                    text: item.title,
                    href: item.path,
                    isActive: page.url == item.path,
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<NavigationNode> _buildNavigationTree(List<Page> pages) {
    final docsPages = pages.where((p) => p.url.startsWith('/docs')).toList();
    final tree = <String, NavigationNode>{};

    for (final page in docsPages) {
      final segments = page.url.split('/').where((e) => e.isNotEmpty).toList();
      if (segments.isEmpty) continue;

      final node = _getOrCreateNode(tree, segments);

      final pageData = page.data.page;
      node.title = (pageData['title'] as String?) ?? node.title;
      node.index = (pageData['index'] as int?) ?? node.index;
    }

    final root = tree['/docs'];
    if (root == null) return [];

    _sortChildren(root);
    return root.children;
  }

  NavigationNode _getOrCreateNode(Map<String, NavigationNode> tree, List<String> segments) {
    final path = '/${segments.join('/')}';
    if (tree.containsKey(path)) return tree[path]!;

    final node = NavigationNode(
      title: segments.last,
      path: path,
      index: 999,
      children: [],
    );
    tree[path] = node;

    if (segments.length > 1) {
      final parentSegments = segments.sublist(0, segments.length - 1);
      final parent = _getOrCreateNode(tree, parentSegments);

      // Check if node is already added to parent's children (due to recursion/map order)
      if (!parent.children.any((c) => c.path == node.path)) {
        parent.children.add(node);
      }
    }

    return node;
  }

  void _sortChildren(NavigationNode node) {
    node.children.sort((a, b) => a.index.compareTo(b.index));
    for (final child in node.children) {
      _sortChildren(child);
    }
  }
}

class NavigationNode {
  String title;
  final String path;
  int index;
  final List<NavigationNode> children;

  NavigationNode({
    required this.title,
    required this.path,
    required this.index,
    this.children = const [],
  });
}

class _SidebarSection extends StatelessComponent {
  final String title;
  final List<_SidebarItem> items;

  _SidebarSection({required this.title, required this.items});

  @override
  Component build(BuildContext context) {
    return div([
      h5(
        classes: 'font-label text-[10px] font-bold tracking-widest text-on-surface-variant uppercase mb-4 opacity-60',
        [Component.text(title)],
      ),
      ul(classes: 'space-y-3', items),
    ]);
  }
}

class _SidebarItem extends StatelessComponent {
  final String text;
  final String href;
  final bool isActive;

  _SidebarItem({required this.text, required this.href, required this.isActive});

  @override
  Component build(BuildContext context) {
    return li([
      a(
        classes: isActive
            ? 'flex items-center gap-3 text-sm font-medium text-primary'
            : 'flex items-center gap-3 text-sm font-medium text-on-surface-variant hover:text-on-surface transition-colors pl-4',
        href: href,
        [
          if (isActive)
            span(
              classes: 'w-1.5 h-1.5 rounded-full bg-primary shadow-[0_0_8px_rgba(59,191,250,0.8)]',
              [],
            ),
          Component.text(text),
        ],
      ),
    ]);
  }
}
