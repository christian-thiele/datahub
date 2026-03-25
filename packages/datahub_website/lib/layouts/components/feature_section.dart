import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class FeatureSection extends StatelessComponent {
  const FeatureSection();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'py-24 bg-surface-container-low mb-32',
      [
        div(
          classes: 'max-w-7xl mx-auto px-6',
          [
            div(
              classes: 'mb-16 text-center',
              [
                h2(classes: 'text-4xl font-headline font-bold tracking-tight mb-4', [Component.text('Engineered for Velocity')]),
                p(classes: 'text-on-surface-variant max-w-2xl mx-auto', [
                  Component.text("We've removed the friction between your code and the cloud. Everything you need is already here.")
                ]),
              ],
            ),
            div(
              classes: 'grid grid-cols-1 md:grid-cols-3 gap-6',
              [
                // Feature 1
                div(
                  classes:
                      'md:col-span-2 group relative bg-surface-container p-8 rounded-xl border border-outline-variant/10 hover:border-primary/30 transition-all flex flex-col justify-between min-h-[400px] overflow-hidden',
                  [
                    div(
                      classes: 'relative z-10',
                      [
                        div(
                          classes:
                              'w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center text-primary mb-6 group-hover:scale-110 transition-transform',
                          [span(classes: 'material-symbols-outlined text-3xl', [Component.text('terminal')])],
                        ),
                        h3(classes: 'text-2xl font-headline font-bold mb-3', [Component.text('Batteries Included')]),
                        p(classes: 'text-on-surface-variant max-w-md', [
                          Component.text('All your favorite tools, pre-configured. From Redis to Postgres, deployment happens in seconds, not hours. No more configuration hell.')
                        ]),
                      ],
                    ),
                    div(
                      classes: 'mt-8 flex gap-4',
                      [
                        for (final tech in ['Kubernetes', 'Docker', 'Redis'])
                          div(
                            classes: 'px-3 py-1 rounded bg-surface-container-highest text-[10px] font-bold text-on-surface-variant tracking-widest uppercase',
                            [Component.text(tech)],
                          ),
                      ],
                    ),
                    div(classes: 'absolute top-0 right-0 -mr-16 -mt-16 w-64 h-64 bg-primary/5 rounded-full blur-3xl group-hover:bg-primary/10 transition-all', []),
                  ],
                ),
                // Feature 2
                div(
                  classes: 'group bg-surface p-8 rounded-xl border border-outline-variant/10 hover:border-secondary/30 transition-all flex flex-col min-h-[400px]',
                  [
                    div(
                      classes: 'w-12 h-12 rounded-lg bg-secondary/10 flex items-center justify-center text-secondary mb-6 group-hover:rotate-12 transition-transform',
                      [span(classes: 'material-symbols-outlined text-3xl', [Component.text('verified_user')])],
                    ),
                    h3(classes: 'text-2xl font-headline font-bold mb-3', [Component.text('Secure by Default')]),
                    p(classes: 'text-on-surface-variant', [
                      Component.text('Enterprise-grade security baked in. Automatic SSL, SOC2 compliance tools, and end-to-end encryption are standard for every project.')
                    ]),
                    div(
                      classes: 'mt-auto pt-8',
                      [
                        div(
                          classes: 'aspect-video bg-surface-container-low rounded-lg border border-outline-variant/20 flex items-center justify-center',
                          [span(classes: 'material-symbols-outlined text-4xl text-on-surface-variant/30', [Component.text('shield_with_heart')])],
                        ),
                      ],
                    ),
                  ],
                ),
                // Feature 3
                div(
                  classes: 'group bg-surface p-8 rounded-xl border border-outline-variant/10 hover:border-tertiary/30 transition-all flex flex-col min-h-[400px]',
                  [
                    div(
                      classes: 'w-12 h-12 rounded-lg bg-tertiary/10 flex items-center justify-center text-tertiary mb-6 group-hover:-translate-y-1 transition-transform',
                      [span(classes: 'material-symbols-outlined text-3xl', [Component.text('monitoring')])],
                    ),
                    h3(classes: 'text-2xl font-headline font-bold mb-3', [Component.text('Instant Observability')]),
                    p(classes: 'text-on-surface-variant', [
                      Component.text("Real-time logs, metrics, and tracing. Know exactly what's happening in your stack without installing a single agent.")
                    ]),
                  ],
                ),
                // Feature 4
                div(
                  classes: 'md:col-span-2 group bg-surface-container-highest p-8 rounded-xl border border-outline-variant/10 hover:border-primary/30 transition-all flex flex-col md:flex-row gap-8 items-center min-h-[300px]',
                  [
                    div(
                      classes: 'flex-1',
                      [
                        div(
                          classes: 'w-12 h-12 rounded-lg bg-primary-container/20 flex items-center justify-center text-primary-container mb-6',
                          [span(classes: 'material-symbols-outlined text-3xl', [Component.text('rocket_launch')])],
                        ),
                        h3(classes: 'text-2xl font-headline font-bold mb-3', [Component.text('Rapid Scaling')]),
                        p(classes: 'text-on-surface-variant', [
                          Component.text('Grow from one to a million users instantly. Our elastic edge network distributes your workload globally with sub-50ms latency.')
                        ]),
                      ],
                    ),
                    div(
                      classes: 'flex-1 w-full',
                      [
                        div(
                          classes: 'p-4 bg-surface-container-lowest rounded-lg border border-outline-variant/10 shadow-inner',
                          [
                            div(
                              classes: 'flex justify-between items-end h-24 gap-2',
                              [
                                div(classes: 'bg-primary/20 w-full rounded-t-sm h-1/4', []),
                                div(classes: 'bg-primary/30 w-full rounded-t-sm h-2/4', []),
                                div(classes: 'bg-primary/40 w-full rounded-t-sm h-1/3', []),
                                div(classes: 'bg-primary/60 w-full rounded-t-sm h-3/4', []),
                                div(classes: 'bg-primary w-full rounded-t-sm h-full shadow-[0_0_12px_rgba(59,191,250,0.5)]', []),
                              ],
                            ),
                            div(
                              classes: 'flex justify-between mt-2 text-[8px] uppercase tracking-widest text-on-surface-variant/40',
                              [
                                span([Component.text('T-Minus 1h')]),
                                span([Component.text('Peak Load')]),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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
