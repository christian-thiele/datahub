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
              'max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-x-8 gap-y-16',
          [
            div(classes: 'col-span-1 md:col-span-3 lg:md:col-span-2', [
              span(
                classes:
                    'text-lg font-black tracking-widest text-slate-200 uppercase font-headline',
                [Component.text('DataHub'), br()],
              ),

              span(
                classes:
                    'text-md font-black tracking-widest text-slate-500 uppercase font-headline',
                [Component.text('by ReactiveData')],
              ),

              p(classes: 'mt-4 text-xs text-slate-500 font-body leading-loose max-w-xs', [
                Component.text(
                    'The Cloud Development Ecosystem bringing the power of Dart to the Cloud'),
              ]),

              p(classes: 'mt-4 text-xs text-slate-500 font-label', [
                Component.text('© 2026 Christian Thiele'),
              ]),
            ]),
            div(classes: 'flex flex-col gap-4', [
              h6(
                classes:
                'font-body text-xs tracking-wide uppercase font-semibold text-slate-500',
                [Component.text('About')],
              ),
              a(
                classes:
                'text-slate-500 hover:text-slate-300 text-sm transition-opacity opacity-80 hover:opacity-100',
                href: 'https://reactivedata.de/',
                [Component.text('ReactiveData')],
              ),
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
                href: 'https://github.com/christian-thiele/datahub/blob/main/CHANGELOG.md',
                [Component.text('Changelog')],
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
                href: 'https://reactivedata.de/impressum',
                [Component.text('Imprint')],
              ),
              a(
                classes:
                'text-slate-500 hover:text-slate-300 text-sm transition-opacity opacity-80 hover:opacity-100',
                href: 'https://reactivedata.de/datenschutz',
                [Component.text('Privacy')],
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
