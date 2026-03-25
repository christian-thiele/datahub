import 'package:datahub_website/layouts/components/hero_elements.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class HeroSection extends StatelessComponent {
  const HeroSection();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative pt-32 pb-20 md:pt-48 md:pb-32 overflow-hidden',
      [
        div(classes: 'absolute inset-0 hero-gradient -z-10', []),
        div(
          classes: 'max-w-7xl mx-auto px-6 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center',
          [
            div(
              classes: 'lg:col-span-7',
              [
                HeroBadge(icon: 'bolt', label: 'Next-Gen Infrastructure'),
                HeroTitle(children: [
                  Component.text('Secure-by-Default '),
                  br(),
                  span(classes: 'text-primary', [Component.text('Development, Simplified.')]),
                ]),
                HeroDescription(
                    'Deploy with confidence. Our batteries-included platform streamlines your developer workflow with world-class security baked into every byte.'),
                HeroActions(children: [
                  HeroPrimaryButton(label: 'Start Developing for Free'),
                  HeroSecondaryButton(label: 'View Documentation'),
                ]),
                HeroTrustedBy(
                  label: 'Trusted by teams at',
                  companies: ['HEXA', 'QUANTUM', 'VOID'],
                ),
              ],
            ),
            HeroTerminal(),
          ],
        ),
      ],
    );
  }
}
