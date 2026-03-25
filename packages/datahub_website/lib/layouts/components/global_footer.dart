import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class GlobalFooter extends StatelessComponent {
  const GlobalFooter();

  @override
  Component build(BuildContext context) {
    return footer(
      classes: 'bg-slate-950 w-full py-12 px-8 border-t border-slate-900',
      [
        div(
          classes:
              'max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-8',
          [
            div(classes: 'col-span-2', [
              span(
                classes:
                    'text-lg font-black tracking-widest text-slate-200 uppercase font-headline',
                [Component.text('DataHub')],
              ),
              p(classes: 'mt-4 text-xs text-slate-500 font-body leading-loose max-w-xs', [
                Component.text(
                    'Engineering Excellence. Powering the next generation of cloud-native applications with precision-built infrastructure.'),
              ]),
            ]),
            div(classes: 'flex flex-col gap-4', [
              h6(
                classes:
                    'font-body text-xs tracking-wide uppercase font-semibold text-slate-500',
                [Component.text('Resources')],
              ),
              a(
                classes:
                    'text-slate-500 hover:text-slate-300 text-sm transition-opacity opacity-80 hover:opacity-100',
                href: '/docs',
                [Component.text('Documentation')],
              ),
              a(
                classes:
                    'text-slate-500 hover:text-slate-300 text-sm transition-opacity opacity-80 hover:opacity-100',
                href: '#',
                [Component.text('Changelog')],
              ),
              a(
                classes:
                    'text-slate-500 hover:text-slate-300 text-sm transition-opacity opacity-80 hover:opacity-100',
                href: '#',
                [Component.text('Status')],
              ),
            ]),
            div(classes: 'flex flex-col gap-4', [
              h6(
                classes:
                    'font-body text-xs tracking-wide uppercase font-semibold text-slate-500',
                [Component.text('Legal')],
              ),
              a(
                classes:
                    'text-slate-500 hover:text-slate-300 text-sm transition-opacity opacity-80 hover:opacity-100',
                href: '#',
                [Component.text('Privacy')],
              ),
              a(
                classes:
                    'text-slate-500 hover:text-slate-300 text-sm transition-opacity opacity-80 hover:opacity-100',
                href: '#',
                [Component.text('Terms')],
              ),
              a(
                classes:
                    'text-slate-500 hover:text-slate-300 text-sm transition-opacity opacity-80 hover:opacity-100',
                href: '#',
                [Component.text('Security')],
              ),
            ]),
            div(classes: 'col-span-2 lg:col-span-2 flex flex-col justify-end', [
              p(classes: 'text-xs text-slate-500 font-label', [
                Component.text('© 2026 DataHub. Engineering Excellence.'),
              ]),
            ]),
          ],
        ),
      ],
    );
  }
}
