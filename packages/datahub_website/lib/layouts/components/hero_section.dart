import 'package:datahub_website/layouts/components/hero_elements.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class HeroSection extends StatelessComponent {
  final String headline1;
  final String headline2;
  final Component child;

  const HeroSection({super.key, required this.headline1, required this.headline2, required this.child});

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative pt-32 pb-20 md:pt-16 min-h-screen overflow-hidden flex items-center',
      [
        div(classes: 'absolute inset-0 hero-gradient -z-10', []),
        div(
          classes: 'max-w-7xl mx-auto px-6 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center',
          [
            div(
              classes: 'lg:col-span-7',
              [
                //HeroBadge(icon: 'bolt', label: 'Next-Gen Infrastructure'),
                HeroTitle(
                  children: [
                    Component.text(headline1),
                    br(),
                    span(classes: 'text-primary', [Component.text(headline2)]),
                  ],
                ),
                p(
                  classes: 'text-lg md:text-xl text-on-surface-variant max-w-2xl mb-10 leading-relaxed',
                  [child],
                ),
                HeroActions(
                  children: [
                    HeroPrimaryButton(label: 'Get Started'),
                    HeroSecondaryButton(label: 'Why DataHub?'),
                  ],
                ),
                /*HeroTrustedBy(
                  label: 'Trusted by teams at',
                  companies: ['HEXA', 'QUANTUM', 'VOID'],
                ),*/
              ],
            ),
            HeroTerminal(),
          ],
        ),
      ],
    );
  }
}

class HeroCustomComponent extends CustomComponentBase {
  HeroCustomComponent();

  @override
  final Pattern pattern = 'Hero';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    return HeroSection(
      child: child ?? Component.empty(),
      headline1: attributes['headline1'] ?? '',
      headline2: attributes['headline2'] ?? '',
    );
  }
}
