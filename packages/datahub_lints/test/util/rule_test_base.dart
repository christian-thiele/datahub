import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';

import 'stubs.dart';

/// Base class for rule tests, with the framework stubs wired up.
abstract class DatahubRuleTest extends AnalysisRuleTest {
  /// Packages to stub in addition to `datahub`.
  Map<String, String> get extraStubs => const {};

  @override
  void setUp() {
    addDatahubStub(this);
    extraStubs.forEach((name, source) {
      newPackage(name).addFile('lib/$name.dart', source);
    });
    super.setUp();
  }

  /// Writes the generated part library that a `@Data()` test source expects.
  ///
  /// The builder is not run in these tests, so the generated superclasses are
  /// stubbed here instead. Without this the sample sources carry
  /// `uri_has_not_been_generated` and `extends_non_class` errors that have
  /// nothing to do with the rule under test.
  void writeGeneratedPart(String content) {
    newFile('$testPackageLibPath/test.g.dart', """
part of 'test.dart';

$content
""");
  }

  /// Expects a diagnostic at the first occurrence of [snippet].
  ///
  /// [length] narrows the reported range when the rule anchors to only part of
  /// the snippet, which is often needed to make the snippet unique.
  ExpectedDiagnostic lintOn(String content, String snippet, {int? length}) =>
      lint(offsetOf(content, snippet), length ?? snippet.length);
}
