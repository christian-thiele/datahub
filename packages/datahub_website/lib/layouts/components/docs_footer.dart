import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class DocsFooter extends StatelessComponent {
  const DocsFooter();

  @override
  Component build(BuildContext context) {
    return footer(
      classes:
          'border-t border-outline-variant/20 pt-12 flex flex-col md:flex-row justify-between items-center gap-8',
      [
        div(classes: 'flex items-center gap-4 group cursor-pointer', [
          div(
            classes:
                'p-3 rounded bg-surface-container-low border border-outline-variant/10 group-hover:border-primary/50 transition-all',
            [
              span(
                classes:
                    'material-symbols-outlined text-on-surface-variant group-hover:text-primary transition-all',
                [Component.text('arrow_back')],
              ),
            ],
          ),
          div([
            span(
              classes:
                  'text-[10px] uppercase font-bold text-on-surface-variant tracking-widest opacity-60',
              [Component.text('Previous')],
            ),
            div(
              classes: 'font-headline font-bold text-lg',
              [Component.text('Introduction')],
            ),
          ]),
        ]),
        div(classes: 'flex items-center gap-4 group cursor-pointer text-right', [
          div([
            span(
              classes:
                  'text-[10px] uppercase font-bold text-on-surface-variant tracking-widest opacity-60',
              [Component.text('Next')],
            ),
            div(
              classes: 'font-headline font-bold text-lg',
              [Component.text('CLI Configuration')],
            ),
          ]),
          div(
            classes:
                'p-3 rounded bg-surface-container-low border border-outline-variant/10 group-hover:border-primary/50 transition-all',
            [
              span(
                classes:
                    'material-symbols-outlined text-on-surface-variant group-hover:text-primary transition-all',
                [Component.text('arrow_forward')],
              ),
            ],
          ),
        ]),
      ],
    );
  }
}
