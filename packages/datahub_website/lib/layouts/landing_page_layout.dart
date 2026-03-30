import 'package:datahub_website/layouts/components/global_footer.dart';
import 'package:datahub_website/layouts/components/top_navigation.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import 'base_layout.dart';

class LandingPageLayout extends BaseLayout {
  const LandingPageLayout();

  @override
  Component buildBody(Page page, Component child) {
    return Component.fragment([
      TopNavigation(page: page),
      child,
      const GlobalFooter(),
    ]);
  }

  @override
  Pattern get name => 'landing-page';
}
