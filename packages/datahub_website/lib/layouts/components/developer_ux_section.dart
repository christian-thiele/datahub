import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class DeveloperUxSection extends StatelessComponent {
  const DeveloperUxSection();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'max-w-7xl mx-auto px-6 mb-32',
      [
        div(
          classes: 'bg-surface-container-lowest rounded-2xl border border-outline-variant/20 p-12',
          [
            div(
              classes: 'text-center max-w-2xl mx-auto mb-16',
              [
                h2(classes: 'text-4xl font-headline font-bold tracking-tight mb-4', [Component.text('Developer-Centric UX')]),
                p(classes: 'text-on-surface-variant leading-relaxed', [
                  Component.text('We built the platform we wanted to use. No bloat, just the tools you need to move fast.')
                ]),
              ],
            ),
            div(
              classes: 'grid grid-cols-1 md:grid-cols-3 gap-12',
              [
                _buildUxItem(
                  icon: 'keyboard',
                  title: 'Simple CLI',
                  description: 'One command to deploy. vanguard deploy handles the heavy lifting.',
                  linkText: 'View Docs',
                ),
                _buildUxItem(
                  icon: 'dashboard_customize',
                  title: 'Intuitive Dashboard',
                  description: 'Real-time observability and resource management through a clean, high-performance interface.',
                  linkText: 'Live Demo',
                ),
                _buildUxItem(
                  icon: 'api',
                  title: 'Extensive API',
                  description: 'First-class API access for every single feature. Automate your infrastructure exactly how you want.',
                  linkText: 'Endpoints',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component _buildUxItem({
    required String icon,
    required String title,
    required String description,
    required String linkText,
  }) {
    return div(
      classes: 'group',
      [
        div(
          classes: 'mb-6 inline-flex p-3 rounded-lg bg-surface-variant group-hover:bg-primary transition-colors',
          [
            span(
              classes: 'material-symbols-outlined text-primary group-hover:text-on-primary',
              [Component.text(icon)],
            ),
          ],
        ),
        h4(classes: 'text-xl font-headline font-bold mb-3', [Component.text(title)]),
        p(
          classes: 'text-sm text-on-surface-variant leading-relaxed mb-4',
          [
            if (title == 'Simple CLI') ...[
              Component.text('One command to deploy. '),
              code(classes: 'bg-surface-container-highest px-2 py-1 rounded text-primary', [Component.text('vanguard deploy')]),
              Component.text(' handles the heavy lifting.'),
            ] else
              Component.text(description),
          ],
        ),
        a(
          classes: 'text-xs font-bold text-primary tracking-widest uppercase flex items-center gap-2 hover:gap-4 transition-all',
          href: '#',
          [
            Component.text(linkText),
            span(classes: 'material-symbols-outlined text-sm', [Component.text('arrow_forward')]),
          ],
        ),
      ],
    );
  }
}