import 'package:datahub_website/layouts/base_layout.dart';
import 'package:datahub_website/layouts/components/docs_footer.dart';
import 'package:datahub_website/layouts/components/docs_sidebar.dart';
import 'package:datahub_website/layouts/components/global_footer.dart';
import 'package:datahub_website/layouts/components/top_navigation.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class DocsPageLayout extends BaseLayout {
  const DocsPageLayout();

  @override
  Component buildBody(Page page, Component child) {
    final pageData = page.data.page;

    return Component.fragment([
      TopNavigation(page: page),
      div(classes: 'flex min-h-screen pt-16', [
        DocsSidebar(page: page),
        main_(classes: 'flex-1 lg:ml-72 bg-surface', [
          div(classes: 'max-w-4xl mx-auto px-8 lg:px-16 py-12 md:py-20', [
            if (pageData['title'] case final String title)
              header(classes: 'mb-16', [
                if (pageData['version'] case final String version)
                  div(
                    classes:
                        'inline-flex items-center gap-2 px-2 py-1 rounded-sm bg-secondary-container/20 text-secondary text-[10px] font-bold tracking-widest uppercase mb-4',
                    [
                      span(
                        classes: 'material-symbols-outlined text-[12px]',
                        attributes: {
                          'style': "font-variation-settings: 'FILL' 1",
                        },
                        [Component.text('bolt')],
                      ),
                      Component.text('Version $version'),
                    ],
                  ),

                h1(
                  classes: 'font-headline text-5xl md:text-6xl font-extrabold tracking-tighter text-on-surface mb-6',
                  [Component.text(title)],
                ),
              ]),
            child,
            const DocsFooter(),
          ]),
          const GlobalFooter(),
        ]),
      ]),
    ]);
  }

  @override
  Pattern get name => 'docs';
}
