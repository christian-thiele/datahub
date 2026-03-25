import 'package:datahub_website/layouts/components/cta_section.dart';
import 'package:datahub_website/layouts/components/developer_ux_section.dart';
import 'package:datahub_website/layouts/components/enterprise_security_section.dart';
import 'package:datahub_website/layouts/components/feature_section.dart';
import 'package:datahub_website/layouts/components/global_footer.dart';
import 'package:datahub_website/layouts/components/hero_section.dart';
import 'package:datahub_website/layouts/components/integrated_toolchain_section.dart';
import 'package:datahub_website/layouts/components/testimonials_section.dart';
import 'package:datahub_website/layouts/components/top_navigation.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import 'base_layout.dart';

class LandingPageLayout extends BaseLayout {
  const LandingPageLayout();

  @override
  Component buildBody(Page page, Component child) {
    return Component.fragment([
      TopNavigation(page: page),
      HeroSection(),
      const FeatureSection(),
      const EnterpriseSecuritySection(),
      const IntegratedToolchainSection(),
      const DeveloperUxSection(),
      const TestimonialsSection(),
      const CtaSection(),
      const GlobalFooter(),
    ]);
  }

  @override
  Pattern get name => 'landing-page';
}
