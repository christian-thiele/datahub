import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class IntegratedToolchainSection extends StatelessComponent {
  const IntegratedToolchainSection();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'max-w-7xl mx-auto px-6 mb-32',
      [
        div(
          classes: 'grid grid-cols-1 lg:grid-cols-2 gap-16 items-center',
          [
            div(
              classes: 'order-2 lg:order-1',
              [
                div(
                  classes: 'terminal-trace terminal-trace-active pl-8',
                  [
                    div(
                      classes: 'mb-10',
                      [
                        h4(
                          classes: 'text-primary font-mono text-sm mb-2 font-bold tracking-widest uppercase',
                          [Component.text('Tooling // CI/CD')],
                        ),
                        h2(classes: 'text-4xl font-headline font-bold tracking-tight mb-4', [Component.text('Integrated Toolchain')]),
                        p(classes: 'text-on-surface-variant leading-relaxed', [
                          Component.text("Don't waste weeks on plumbing. Our \"Batteries Included\" approach provides the entire development lifecycle out of the box.")
                        ]),
                      ],
                    ),
                    div(
                      classes: 'space-y-8',
                      [
                        _buildToolItem(
                          icon: 'terminal',
                          title: 'Modern CI/CD Pipelines',
                          description: 'Declarative pipeline syntax with native support for ephemeral build environments.',
                        ),
                        _buildToolItem(
                          icon: 'token',
                          title: 'Container Management',
                          description: 'Orchestration without the complexity. Managed registry and rolling deployments come standard.',
                        ),
                        _buildToolItem(
                          icon: 'integration_instructions',
                          title: 'IDE Extensions',
                          description: 'Native plugins for VS Code and JetBrains to bridge the gap between local and cloud.',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            div(
              classes: 'order-1 lg:order-2',
              [
                div(
                  classes: 'aspect-square rounded-xl bg-surface-container-low border border-outline-variant/10 p-2 overflow-hidden',
                  [
                    img(
                      alt: 'IDE workspace',
                      classes: 'w-full h-full object-cover rounded-lg opacity-80',
                      src: 'https://lh3.googleusercontent.com/aida-public/AB6AXuApiwaRISH2eKkkHudtqEt71PheCNHyPD9ng4YMmhzOMg9wEc_d4psolXxpWkgDXTHd9bDkNj18tJaUmEvVKSz11bZkLX_KRGBc1a6UONyQGORsztM2pP8d5flW-zhU742436EoaZQ_r_hBg2X3D4ZfKEau52t258YG2A-tz8_euK4PJTQLuvtK8F9EP76PQMpvl8ltrNdlZM7floicj_A3qvnMLE7mzNz_xYfuvmVssOCBZ5h_6m2mACAiYhomaHYb9EPhy8gzqhcY',
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

  Component _buildToolItem({required String icon, required String title, required String description}) {
    return div(
      classes: 'flex gap-6',
      [
        div(
          classes: 'w-12 h-12 shrink-0 bg-surface-variant rounded-md flex items-center justify-center border border-outline-variant/20',
          [
            span(classes: 'material-symbols-outlined text-primary', [Component.text(icon)]),
          ],
        ),
        div(
          [
            h5(classes: 'font-bold text-lg mb-1', [Component.text(title)]),
            p(classes: 'text-sm text-on-surface-variant', [Component.text(description)]),
          ],
        ),
      ],
    );
  }
}
