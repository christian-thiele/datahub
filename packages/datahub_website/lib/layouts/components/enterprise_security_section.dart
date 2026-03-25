import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class EnterpriseSecuritySection extends StatelessComponent {
  const EnterpriseSecuritySection();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'max-w-7xl mx-auto px-6 mb-32',
      [
        div(
          classes: 'flex items-center justify-between mb-12',
          [
            h2(classes: 'text-3xl font-headline font-bold tracking-tight', [Component.text('Enterprise Security')]),
            div(classes: 'h-px flex-grow mx-8 bg-outline-variant/30', []),
            span(classes: 'text-primary font-mono text-sm', [Component.text('SEC-OPS // 01')]),
          ],
        ),
        div(
          classes: 'grid grid-cols-1 md:grid-cols-12 gap-6',
          [
            // Large Card: Zero Trust
            div(
              classes: 'md:col-span-8 glass-panel rounded-xl p-8 border border-outline-variant/15 relative overflow-hidden group',
              [
                div(
                  classes: 'relative z-10',
                  [
                    span(
                      classes: 'material-symbols-outlined text-primary text-4xl mb-6',
                      [Component.text('shield_lock')],
                    ),
                    h3(classes: 'text-2xl font-headline font-bold mb-4', [Component.text('Zero-Trust Architecture')]),
                    p(classes: 'text-on-surface-variant max-w-lg mb-6 leading-relaxed', [
                      Component.text('Every request is verified, every connection is encrypted. Our micro-segmentation ensures that internal traffic is as secure as public-facing gateways.')
                    ]),
                    ul(
                      classes: 'space-y-3',
                      [
                        li(
                          classes: 'flex items-center gap-3 text-sm text-on-surface',
                          [
                            span(
                              classes: 'material-symbols-outlined text-secondary text-lg',
                              [Component.text('check_circle')],
                            ),
                            Component.text('mTLS by default for all service communication'),
                          ],
                        ),
                        li(
                          classes: 'flex items-center gap-3 text-sm text-on-surface',
                          [
                            span(
                              classes: 'material-symbols-outlined text-secondary text-lg',
                              [Component.text('check_circle')],
                            ),
                            Component.text('Identity-aware proxy for administrative access'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                div(
                  classes: 'absolute right-0 bottom-0 w-1/2 h-full opacity-20 group-hover:opacity-30 transition-opacity',
                  [
                    img(
                      alt: 'security visualization',
                      classes: 'w-full h-full object-cover grayscale',
                      src: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBq9wtWxz4EVRm8m41g_1GSSmYq5_GX9KXSSK5gbKP-QJ80RinTTFFXS8qKhPtAwifQjRnxxgeEG0bMdngt9vHM-3o3Io7FKUFtLRrg-HbFaE6gOMrvMuM92PEP-kzkrbCSYm6cbAF1mvAGKONAYphEokTOj_QgA6q9R_eKyv5CRxktL1d2kgkurnzTJRV-jEef84qxDuP0KNt4CdpZX5kjFJQLI73lZPhSP2YT-OYxpV0DQ4PvNeX8XYcxu-k3k-pZeLLHQgNDG44T',
                    ),
                  ],
                ),
              ],
            ),
            // Small Card: Scanning
            div(
              classes: 'md:col-span-4 bg-surface-container-high rounded-xl p-8 border border-outline-variant/15',
              [
                span(
                  classes: 'material-symbols-outlined text-error text-4xl mb-6',
                  [Component.text('radar')],
                ),
                h3(classes: 'text-xl font-headline font-bold mb-4', [Component.text('Automated Vulnerability Scanning')]),
                p(classes: 'text-sm text-on-surface-variant leading-relaxed', [
                  Component.text('Continuous scanning of container images and dependencies. We catch CVEs before they reach production.')
                ]),
                div(
                  classes: 'mt-8 pt-8 border-t border-outline-variant/20',
                  [
                    div(
                      classes: 'flex items-center justify-between mb-2',
                      [
                        span(classes: 'text-[10px] font-bold text-on-surface-variant uppercase tracking-widest', [Component.text('Live Status')]),
                        span(classes: 'flex h-2 w-2 rounded-full bg-secondary shadow-[0_0_8px_#69f6b8]', []),
                      ],
                    ),
                    div(classes: 'text-xs font-mono text-secondary', [Component.text('NO THREATS DETECTED')]),
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
