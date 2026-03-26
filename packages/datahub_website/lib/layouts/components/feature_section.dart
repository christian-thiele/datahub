import 'package:datahub_website/layouts/components/developer_ux_section.dart';
import 'package:datahub_website/layouts/components/enterprise_security_section.dart';
import 'package:datahub_website/layouts/components/integrated_toolchain_section.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class FeatureSection extends StatelessComponent {
  const FeatureSection();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'pt-16 pb-24 bg-surface-container-low mb-32',
      [
        div(
          classes: 'max-w-7xl mx-auto px-6',
          [
            div(
              classes: 'mb-16 text-center',
              [
                h2(classes: 'text-4xl font-headline font-bold tracking-tight mb-4', [
                  Component.text('Engineered for Velocity'),
                ]),
                p(classes: 'text-on-surface-variant max-w-2xl mx-auto', [
                  Component.text(
                    "DataHub removes the friction between your code and the cloud. Everything you need is already here.",
                  ),
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
                          [
                            span(classes: 'material-symbols-outlined text-3xl', [Component.text('data_object')]),
                          ],
                        ),
                        h3(classes: 'text-2xl font-headline font-bold mb-3', [
                          Component.text('Model Once. Use Everywhere.'),
                        ]),
                        p(classes: 'text-on-surface-variant max-w-md', [
                          Component.text(
                            'Define your data once — use it across your entire system. DataHub automatically integrates your models with databases, APIs, brokers, and services.',
                          ),
                        ]),
                      ],
                    ),
                    /*
                    div(
                      classes: 'mt-8 flex gap-4',
                      [
                        for (final tech in ['Kubernetes', 'Docker', 'Redis'])
                          div(
                            classes:
                                'px-3 py-1 rounded bg-surface-container-highest text-[10px] font-bold text-on-surface-variant tracking-widest uppercase',
                            [Component.text(tech)],
                          ),
                      ],
                    ),*/
                    div(
                      classes:
                          'absolute top-0 right-0 -mr-16 -mt-16 w-64 h-64 bg-primary/5 rounded-full blur-3xl group-hover:bg-primary/10 transition-all',
                      [],
                    ),
                  ],
                ),
                // Feature 2
                div(
                  classes:
                      'group bg-surface p-8 rounded-xl border border-outline-variant/10 hover:border-secondary/30 transition-all flex flex-col min-h-[400px]',
                  [
                    div(
                      classes: 'relative z-10',
                      [
                        div(
                          classes:
                              'w-12 h-12 rounded-lg bg-secondary/10 flex items-center justify-center text-secondary mb-6 group-hover:scale-110 transition-transform',
                          [
                            span(classes: 'material-symbols-outlined text-3xl', [Component.text('verified_user')]),
                          ],
                        ),
                        h3(classes: 'text-2xl font-headline font-bold mb-3', [Component.text('Secure by Default')]),
                        p(classes: 'text-on-surface-variant', [
                          Component.text(
                            'Enterprise-grade security baked in. No need to worry about authentication, access control or encryption. DataHub provides all the tools to develop secure systems from the start.',
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
                // Feature 3
                div(
                  classes:
                      'group bg-surface p-8 rounded-xl border border-outline-variant/10 hover:border-tertiary/30 transition-all flex flex-col min-h-[400px]',
                  [
                    div(
                      classes: 'relative z-10',
                      [
                        div(
                          classes:
                              'w-12 h-12 rounded-lg bg-tertiary/10 flex items-center justify-center text-tertiary mb-6 group-hover:scale-110 transition-transform',
                          [
                            span(classes: 'material-symbols-outlined text-3xl', [Component.text('monitoring')]),
                          ],
                        ),
                        h3(classes: 'text-2xl font-headline font-bold mb-3', [Component.text('Instant Observability')]),
                        p(classes: 'text-on-surface-variant', [
                          Component.text(
                            "Real-time logs, metrics, and tracing. Use built-in visibility tools or integrate seamlessly via OpenTelemetry APIs.",
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
                // Feature 4
                div(
                  classes:
                      'md:col-span-2 group bg-surface-container-highest p-8 rounded-xl border border-outline-variant/10 hover:border-primary/30 transition-all flex flex-col md:flex-row gap-8 min-h-[300px]',
                  [
                    div(
                      classes: 'relative z-10',
                      [
                        div(
                          classes:
                              'w-12 h-12 rounded-lg bg-primary-container/20 flex items-center justify-center text-primary-container mb-6 group-hover:scale-110 transition-all',
                          [
                            span(classes: 'material-symbols-outlined text-3xl', [Component.text('rocket_launch')]),
                          ],
                        ),
                        h3(classes: 'text-2xl font-headline font-bold mb-3', [
                          Component.text('Effortless scalability'),
                        ]),
                        p(classes: 'text-on-surface-variant', [
                          Component.text(
                            'Don\'t get locked in by early architectural decisions. Start simple or design for scale — whether monolith, microservices, or something in between. Evolve and restructure your architecture at any time with minimal effort.',
                          ),
                        ]),
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

class FeatureSectionCustomComponent extends CustomComponentBase {
  FeatureSectionCustomComponent();

  @override
  final Pattern pattern = 'FeatureSection';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    return Component.fragment([
      FeatureSection(),
    ]);
  }
}
