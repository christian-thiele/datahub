library;

import 'dart:io';

import 'package:datahub_website/layouts/docs_page_layout.dart';
import 'package:jaspr/server.dart';

import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/components/code_block.dart';
import 'package:jaspr_content/components/image.dart';
import 'package:jaspr_content/components/sidebar.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'layouts/landing_page_layout.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  Highlighter.addLanguage('shell', File('shell_grammar.json').readAsStringSync());
  Highlighter.addLanguage('bash', File('shell_grammar.json').readAsStringSync());

  runApp(
    ContentApp(
      templateEngine: MustacheTemplateEngine(),
      eagerlyLoadAllPages: true,
      parsers: [
        MarkdownParser(),
      ],
      extensions: [
        HeadingAnchorsExtension(),
        TableOfContentsExtension(),
      ],
      components: [
        Callout(),
        CodeBlock(),
        Image(zoom: true),
      ],
      layouts: [
        DocsPageLayout(),
        LandingPageLayout(),
      ],
      theme: ContentTheme(
        primary: ThemeColor(ThemeColors.sky.$600, dark: ThemeColors.sky.$400),
        background: ThemeColor(ThemeColors.slate.$50, dark: ThemeColors.zinc.$950),
        colors: [
          ContentColors.text.apply(ThemeColors.slate.$300),
          ContentColors.headings.apply(ThemeColors.slate.$100),
          ContentColors.links.apply(ThemeColors.sky.$400),
          ContentColors.quoteBorders.apply(ThemeColors.sky.$800),
          ContentColors.code.apply(ThemeColors.sky.$400),
          ContentColors.preBg.apply(ThemeColors.zinc.$900),
        ],
      ),
    ),
  );
}
