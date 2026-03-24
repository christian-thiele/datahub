/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

// Server-specific Jaspr import.
import 'package:jaspr/server.dart';

import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/components/code_block.dart';
import 'package:jaspr_content/components/github_button.dart';
import 'package:jaspr_content/components/header.dart';
import 'package:jaspr_content/components/image.dart';
import 'package:jaspr_content/components/sidebar.dart';
import 'package:jaspr_content/components/theme_toggle.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  // Starts the app.
  //
  // [ContentApp] spins up the content rendering pipeline from jaspr_content to render
  // your markdown files in the content/ directory to a beautiful documentation site.
  runApp(
    ContentApp(
      // Enables mustache templating inside the markdown files.
      templateEngine: MustacheTemplateEngine(),
      parsers: [
        MarkdownParser(),
      ],
      extensions: [
        // Adds heading anchors to each heading.
        HeadingAnchorsExtension(),
        // Generates a table of contents for each page.
        TableOfContentsExtension(),
      ],
      components: [
        // The <Info> block and other callouts.
        Callout(),
        // Adds syntax highlighting to code blocks.
        CodeBlock(),
        // Adds zooming and caption support to images.
        Image(zoom: true),
      ],
      layouts: [
        // Out-of-the-box layout for documentation sites.
        DocsLayout(
          header: Header(
            title: 'DataHub',
            logo: '/images/logo.svg',
            items: [
              ThemeToggle(),
              GitHubButton(repo: 'christian-thiele/datahub'),
            ],
          ),
          sidebar: Sidebar(
            groups: [
              SidebarGroup(
                links: [
                  SidebarLink(text: "Overview", href: '/'),
                  SidebarLink(text: "Features", href: '/features'),
                  SidebarLink(text: "Setup", href: '/setup'),
                ],
              ),
              SidebarGroup(
                title: 'Documentation',
                links: [
                  SidebarLink(text: "Tutorials", href: '/docs/tutorials'),
                  SidebarLink(text: "Guides", href: '/docs/guides'),
                  SidebarLink(text: "API Reference", href: '/docs/api'),
                ],
              ),
              SidebarGroup(
                title: 'API Packages',
                links: [
                  SidebarLink(text: "Boost", href: '/docs/api/boost'),
                  SidebarLink(text: "DataHub", href: '/docs/api/datahub'),
                  SidebarLink(text: "DataHub AMQP", href: '/docs/api/datahub_amqp'),
                  SidebarLink(text: "DataHub Aperture", href: '/docs/api/datahub_aperture'),
                  SidebarLink(text: "DataHub Postgres", href: '/docs/api/datahub_postgres'),
                  SidebarLink(text: "DataHub Codegen", href: '/docs/api/datahub_codegen'),
                ],
              ),
            ],
          ),
        ),
      ],
      theme: ContentTheme(
        // Customizes the default theme colors.
        primary: ThemeColor(ThemeColors.blue.$500, dark: ThemeColors.blue.$300),
        background: ThemeColor(ThemeColors.slate.$50, dark: ThemeColors.zinc.$950),
        colors: [
          ContentColors.quoteBorders.apply(ThemeColors.blue.$400),
        ],
      ),
    ),
  );
}
