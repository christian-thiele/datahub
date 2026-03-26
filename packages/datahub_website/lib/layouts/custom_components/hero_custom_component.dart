import 'package:datahub_website/layouts/components/hero_section.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

class HeroCustomComponent extends CustomComponentBase {
  HeroCustomComponent();

  @override
  final Pattern pattern = 'hero';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    return HeroSection(
      child: child ?? Component.empty(),
      headline1: attributes['headline1'] ?? '',
      headline2: attributes['headline2'] ?? '',
    );
  }
}
