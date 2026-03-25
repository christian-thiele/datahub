import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/components/github_button.dart';

// Top-level navigation bar composed of smaller, reusable pieces.
class TopNavigation extends StatelessComponent {
  final Page page;

  const TopNavigation({required this.page});

  @override
  Component build(BuildContext context) {
    final topNavigationConfig = page.data.site['topNavigation'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final linkList = topNavigationConfig['links'] as List<dynamic>? ?? <dynamic>[];
    final links = linkList.map((e) => (e['title'] as String, e['url'] as String)).toList();

    return nav(
      classes:
          'fixed top-0 w-full z-50 bg-slate-950/60 backdrop-blur-xl border-b border-slate-800/50 shadow-2xl shadow-sky-900/20',
      [
        div(
          classes: 'flex justify-between items-center max-w-7xl mx-auto px-6 h-16',
          [
            div(
              classes: 'text-xl font-bold tracking-tighter text-slate-50 dark:text-slate-50 font-headline uppercase',
              [Component.text(topNavigationConfig['title'] as String)],
            ),
            div(
              classes: "hidden md:flex gap-8 items-center font-headline tracking-tight text-sm font-medium",
              [
                for (final (title, url) in links)
                  a(
                    classes: isActive(page, url)
                        ? 'text-sky-400 border-b-2 border-sky-400 pb-1'
                        : 'text-slate-400 hover:text-slate-100 transition-colors',
                    href: url,
                    [
                      Component.text(title),
                    ],
                  ),
              ],
            ),
            div(
              classes: 'flex items-center gap-4',
              [
                GitHubButton(repo: 'christian-thiele/datahub'),
                /*button(
                  classes: 'px-4 py-2 text-sm font-medium text-slate-400 hover:text-slate-100 transition-colors',
                  [Component.text('Log In')],
                ),
                button(
                  classes:
                      'px-5 py-2 rounded-md bg-gradient-to-r from-primary to-primary-container text-on-primary text-sm font-bold active:scale-95 duration-200 transition-all shadow-lg shadow-primary/20',
                  [Component.text('Sign Up')],
                ),*/
              ],
            ),
          ],
        ),
      ],
    );
  }

  bool isActive(Page page, String url) {
    if (url == '/') {
      return page.url == '/';
    }

    final sanitizedPath = page.url.endsWith('/') ? page.url : '${page.url}/';
    return sanitizedPath.startsWith(url);
  }
}
