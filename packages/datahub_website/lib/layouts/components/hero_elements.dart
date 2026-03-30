import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class HeroBadge extends StatelessComponent {
  final String icon;
  final String label;

  const HeroBadge({required this.icon, required this.label});

  @override
  Component build(BuildContext context) {
    return div(
      classes:
          'inline-flex items-center gap-2 px-3 py-1 rounded-full bg-secondary-container text-secondary text-xs font-bold tracking-widest uppercase mb-6',
      [
        span(
          classes: 'material-symbols-outlined text-[14px]',
          attributes: {'style': "font-variation-settings: 'FILL' 1"},
          [Component.text(icon)],
        ),
        Component.text(label),
      ],
    );
  }
}

class HeroTitle extends StatelessComponent {
  final List<Component> children;

  const HeroTitle({required this.children});

  @override
  Component build(BuildContext context) {
    return h1(
      classes: 'text-5xl md:text-7xl font-headline font-bold tracking-tighter leading-[1.1] mb-6 text-on-surface',
      children,
    );
  }
}

class HeroActions extends StatelessComponent {
  final List<Component> children;

  const HeroActions({required this.children});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'flex flex-col sm:flex-row gap-4',
      children,
    );
  }
}

class HeroPrimaryButton extends StatelessComponent {
  final String href;
  final String label;

  const HeroPrimaryButton({
    required this.label,
    required this.href,
  });

  @override
  Component build(BuildContext context) {
    return a(
      href: href,
      classes:
          'px-8 py-4 rounded-md bg-gradient-to-r from-primary to-primary-container text-on-primary font-bold text-lg active:scale-95 duration-200 transition-all shadow-xl shadow-primary/30 no-underline',
      [Component.text(label)],
    );
  }
}

class HeroSecondaryButton extends StatelessComponent {
  final String href;
  final String label;

  const HeroSecondaryButton({
    required this.label,
    required this.href,
  });

  @override
  Component build(BuildContext context) {
    return a(
      href: href,
      classes:
          'px-8 py-4 rounded-md border border-outline-variant bg-surface-container-low text-on-surface font-semibold text-lg hover:bg-surface-container transition-all no-underline',
      [Component.text(label)],
    );
  }
}

class HeroTrustedBy extends StatelessComponent {
  final String label;
  final List<String> companies;

  const HeroTrustedBy({required this.label, required this.companies});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'mt-12 flex items-center gap-6 text-on-surface-variant/60',
      [
        span(
          classes: 'text-xs font-label uppercase tracking-widest',
          [Component.text(label)],
        ),
        div(
          classes: 'flex gap-8 grayscale opacity-50',
          [
            for (var company in companies) span(classes: 'font-headline font-bold text-xl', [Component.text(company)]),
          ],
        ),
      ],
    );
  }
}

class HeroTerminal extends StatelessComponent {
  const HeroTerminal();

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'lg:col-span-5 relative',
      [
        div(
          classes: 'glass-panel rounded-xl border border-outline-variant/30 p-4 shadow-2xl relative',
          [
            div(classes: 'absolute -top-4 -left-4 w-24 h-24 bg-primary/20 blur-3xl', []),
            div(
              classes: 'bg-surface-container-lowest rounded-lg h-full overflow-hidden flex flex-col font-mono text-sm',
              [
                div(
                  classes: 'flex items-center gap-2 px-4 py-2 bg-surface-container border-b border-outline-variant/20',
                  [
                    div(
                      classes: 'flex gap-1.5',
                      [
                        div(classes: 'w-2.5 h-2.5 rounded-full bg-red-500/50', []),
                        div(classes: 'w-2.5 h-2.5 rounded-full bg-yellow-500/50', []),
                        div(classes: 'w-2.5 h-2.5 rounded-full bg-green-500/50', []),
                      ],
                    ),
                    /*span(
                      classes: 'text-on-surface-variant/50 text-[10px] ml-2 tracking-widest uppercase',
                      [Component.text('dart install datahub')],
                    ),*/
                  ],
                ),
                div(
                  classes: 'p-4 space-y-2',
                  [
                    div(
                      classes: 'flex gap-2',
                      [
                        span(classes: 'text-secondary', [Component.text('\$')]),
                        span(classes: 'text-on-surface', [Component.text('dart install datahub')]),
                      ],
                    ),

                    div(
                      classes: 'flex gap-2',
                      [
                        span(classes: 'text-secondary', [Component.text('\$')]),
                        span(classes: 'text-on-surface', [Component.text('dart pub add datahub')]),
                      ],
                    ),

                    /*
                    div(
                      classes: 'text-on-surface-variant/80',
                      [
                        Component.text('[1/4] Analyzing source code... '),
                        span(classes: 'text-secondary', [Component.text('Done')]),
                      ],
                    ),
                    div(
                      classes: 'text-on-surface-variant/80',
                      [
                        Component.text('[2/4] Running security scan... '),
                        span(classes: 'text-secondary', [Component.text('Passed (0 vulnerabilities)')]),
                      ],
                    ),
                    div(
                      classes: 'text-on-surface-variant/80',
                      [Component.text('[3/4] Optimizing build artifacts...')],
                    ),
                    div(
                      classes: 'flex items-center gap-3',
                      [
                        div(
                          classes: 'h-1.5 w-48 bg-surface-container rounded-full overflow-hidden',
                          [
                            div(
                              classes: 'h-full bg-primary w-2/3 shadow-[0_0_8px_rgba(59,191,250,0.8)]',
                              [],
                            ),
                          ],
                        ),
                        span(classes: 'text-[10px] text-primary', [Component.text('67%')]),
                      ],
                    ),
                    div(
                      classes: 'pt-4 text-on-surface-variant/40 italic',
                      [Component.text('// Deployment traced through secure tunnel...')],
                    ),*/
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
