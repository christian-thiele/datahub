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
              items: section.children.map((item) {
                return _SidebarItem(
                  text: item.title,
                  href: item.path,
                  isActive: page.url == item.path,
                );
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<NavigationNode> _buildNavigationTree(List<Page> pages) {
    final docsPages = pages.where((p) => p.url.startsWith('/docs')).toList();

    // Grouping strategy:
    // /docs -> Fundamentals (root level)
    // /docs/tutorials/* -> Tutorials
    // /docs/guides/* -> Guides
    // /docs/api/* -> API Reference

    final sections = <String, List<NavigationNode>>{};

    for (final p in docsPages) {
      final title = p.data.page['title'] as String? ?? 'Untitled';
      final url = p.url;

      String sectionTitle;
      if (url == '/docs') {
        sectionTitle = 'Fundamentals';
      } else if (url.startsWith('/docs/tutorials')) {
        sectionTitle = 'Tutorials';
      } else if (url.startsWith('/docs/guides')) {
        sectionTitle = 'Guides';
      } else if (url.startsWith('/docs/api')) {
        sectionTitle = 'API Reference';
      } else {
        sectionTitle = 'Other';
      }

      sections.putIfAbsent(sectionTitle, () => []).add(NavigationNode(
            title: title,
            path: url,
          ));
    }

    // Sort sections and nodes
    final result = <NavigationNode>[];
    const sectionOrder = ['Fundamentals', 'Tutorials', 'Guides', 'API Reference'];

    for (final title in sectionOrder) {
      if (sections.containsKey(title)) {
        final nodes = sections[title]!;
        // Sort nodes: index.md (root of section) first, then alphabetically
        nodes.sort((a, b) {
          if (a.path == '/docs' ||
              a.path == '/docs/tutorials' ||
              a.path == '/docs/guides' ||
              a.path == '/docs/api') {
            return -1;
          }
          if (b.path == '/docs' ||
              b.path == '/docs/tutorials' ||
              b.path == '/docs/guides' ||
              b.path == '/docs/api') {
            return 1;
          }
          return a.title.compareTo(b.title);
        });
        result.add(NavigationNode(title: title, path: '', children: nodes));
      }
    }

    return result;
  }
}

class NavigationNode {
  final String title;
  final String path;
  final List<NavigationNode> children;

  NavigationNode({
    required this.title,
    required this.path,
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
