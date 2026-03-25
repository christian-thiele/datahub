import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class CtaSection extends StatelessComponent {
  const CtaSection();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'py-24 relative overflow-hidden',
      [
        div(classes: 'absolute inset-0 bg-primary/5 -z-10', []),
        div(
          classes: 'max-w-5xl mx-auto px-6 text-center',
          [
            div(
              classes: 'glass-panel p-12 md:p-20 rounded-2xl border border-primary/20 shadow-2xl relative overflow-hidden',
              [
                div(
                  classes: 'absolute top-0 right-0 p-8 opacity-10',
                  [span(classes: 'material-symbols-outlined text-[160px]', [Component.text('cloud_sync')])],
                ),
                h2(classes: 'text-4xl md:text-5xl font-headline font-bold tracking-tight mb-6', [Component.text('Ready to build the future?')]),
                p(classes: 'text-xl text-on-surface-variant mb-10 max-w-2xl mx-auto', [
                  Component.text('Start your free 14-day trial today. No credit card required. Unlimited access to our premium developer tools.')
                ]),
                div(
                  classes: 'flex flex-col sm:flex-row justify-center gap-6',
                  [
                    button(
                      classes: 'px-10 py-4 rounded-md bg-gradient-to-r from-primary to-primary-container text-on-primary font-bold text-lg hover:shadow-primary/40 hover:scale-[1.02] transition-all',
                      [Component.text('Get Started Now')],
                    ),
                    button(
                      classes: 'px-10 py-4 rounded-md border border-outline-variant text-on-surface font-semibold text-lg hover:bg-surface-container transition-all',
                      [Component.text('Contact Sales')],
                    ),
                  ],
                ),
                p(
                  classes: 'mt-8 text-xs font-label uppercase tracking-[0.2em] text-on-surface-variant/60',
                  [Component.text('No infrastructure management required')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
