library;

import 'dart:io';

import 'package:datahub_website/layouts/components/usp_section.dart';
import 'package:datahub_website/layouts/docs_page_layout.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'package:jaspr_content/components/code_block.dart';
import 'package:jaspr_content/components/image.dart';
import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart' as highlight;

import 'layouts/components/hero_section.dart';
import 'layouts/landing_page_layout.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  highlight.Highlighter.addLanguage('shell', File('shell_grammar.json').readAsStringSync());
  highlight.Highlighter.addLanguage('bash', File('shell_grammar.json').readAsStringSync());

  runApp(
    ContentApp(
      templateEngine: MustacheTemplateEngine(),
      eagerlyLoadAllPages: true,
      parsers: [MarkdownParser()],
      extensions: [
        HeadingAnchorsExtension(),
        TableOfContentsExtension(),
      ],
      components: [
        Callout(),
        CodeBlock(
          grammars: {
            'shell': File('shell_grammar.json').readAsStringSync(),
            'bash': File('shell_grammar.json').readAsStringSync(),
          },
        ),
        Image(),
        HeroComponent(),
        UspSectionComponent(),
      ],
      layouts: [
        DocsPageLayout(),
        LandingPageLayout(),
      ],
      theme: ContentTheme(
        primary: ThemeColor(Color('#3bbffa'), dark: Color('#3bbffa')),
        background: ThemeColor(Color('#060e20'), dark: Color('#060e20')),
        colors: [
          ColorToken(ContentColors.primary.name, Color('#3bbffa'), dark: Color('#3bbffa')),
          ColorToken(ContentColors.background.name, Color('#060e20'), dark: Color('#060e20')),
          ColorToken(ContentColors.text.name, Color('#dee5ff'), dark: Color('#dee5ff')),
          ColorToken(ContentColors.headings.name, Color('#dee5ff'), dark: Color('#dee5ff')),
          ColorToken(ContentColors.lead.name, Color('#a3aac4'), dark: Color('#a3aac4')),
          ColorToken(ContentColors.links.name, Color('#3bbffa'), dark: Color('#3bbffa')),
          ColorToken(ContentColors.bold.name, Color('#dee5ff'), dark: Color('#dee5ff')),
          ColorToken(ContentColors.counters.name, Color('#3bbffa'), dark: Color('#3bbffa')),
          ColorToken(ContentColors.bullets.name, Color('#69f6b8'), dark: Color('#69f6b8')),
          ColorToken(ContentColors.hr.name, Color('#40485d'), dark: Color('#40485d')),
          ColorToken(ContentColors.quotes.name, Color('#a3aac4'), dark: Color('#a3aac4')),
          ColorToken(ContentColors.quoteBorders.name, Color('#3bbffa'), dark: Color('#3bbffa')),
          ColorToken(ContentColors.captions.name, Color('#a3aac4'), dark: Color('#a3aac4')),
          ColorToken(ContentColors.kbd.name, Color('#dee5ff'), dark: Color('#dee5ff')),
          ColorToken(ContentColors.kbdShadows.name, Color('#000000'), dark: Color('#000000')),
          ColorToken(ContentColors.code.name, Color('#3bbffa'), dark: Color('#3bbffa')),
          ColorToken(ContentColors.preCode.name, Color('#dee5ff'), dark: Color('#dee5ff')),
          ColorToken(ContentColors.preBg.name, Color('#000000'), dark: Color('#000000')),
          ColorToken(ContentColors.thBorders.name, Color('#40485d'), dark: Color('#40485d')),
          ColorToken(ContentColors.tdBorders.name, Color('#40485d'), dark: Color('#40485d')),
        ],
      ),
    ),
  );
}
