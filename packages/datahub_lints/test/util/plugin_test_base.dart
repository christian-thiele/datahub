import 'dart:async';

import 'package:analysis_server_plugin/src/correction/fix_generators.dart';
import 'package:analysis_server_plugin/src/plugin_server.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart' as protocol;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as protocol;
import 'package:analyzer_plugin/protocol/protocol_constants.dart' as protocol;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as protocol;
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    as protocol;
import 'package:analyzer_testing/package_config_file_builder.dart';
import 'package:analyzer_testing/resource_provider_mixin.dart';
import 'package:async/async.dart';
import 'package:datahub_lints/main.dart';
import 'package:test/test.dart';

import 'stubs.dart';

/// Drives the real [PluginServer] with the DataHub plugin registered, so that
/// fixes and assists are exercised through the same path the analysis server
/// uses.
class PluginTestBase with ResourceProviderMixin {
  final channel = _FakeChannel();

  late final PluginServer pluginServer;

  Folder get byteStoreRoot => getFolder('/byteStore');

  Folder get sdkRoot => getFolder('/sdk');

  String get packagePath => convertPath('/package1');

  String get filePath => join(packagePath, 'lib', 'test.dart');

  protocol.ContextRoot get contextRoot => protocol.ContextRoot(packagePath, []);

  Future<void> setUp() async {
    createMockSdk(resourceProvider: resourceProvider, root: sdkRoot);

    pluginServer = PluginServer.new2(
      resourceProvider: resourceProvider,
      plugins: {'datahub_lints': DatahubLintsPlugin()},
    );

    await pluginServer.initialize();
    pluginServer.start(channel);
    await pluginServer.handlePluginVersionCheck(
      protocol.PluginVersionCheckParams(
        byteStoreRoot.path,
        sdkRoot.path,
        '0.0.1',
      ),
    );

    _writeStubPackages();

    final diagnostics = enabledLintRules
        .map((rule) => '      $rule: true')
        .join('\n');

    newAnalysisOptionsYamlFile(packagePath, '''
plugins:
  datahub_lints:
    path: some/path
${diagnostics.isEmpty ? '' : '    diagnostics:\n$diagnostics'}
''');
  }

  /// Lint rules to switch on for this test.
  ///
  /// Warning rules are on by default; rules registered with
  /// `registerLintRule` have to be opted into, exactly as a user would.
  List<String> get enabledLintRules => const [];

  void tearDown() {
    registeredFixGenerators.clearLintProducers();
    registeredFixGenerators.clearWarningProducers();
  }

  /// Stub packages to add beyond `datahub`, keyed by package name.
  Map<String, String> get extraStubs => const {};

  /// Writes the stub framework packages and wires up a package config so that
  /// `package:datahub/datahub.dart` resolves inside the test workspace.
  void _writeStubPackages() {
    final datahubPath = convertPath('/datahub');
    newFile(join(datahubPath, 'lib', 'datahub.dart'), datahubStub);

    final builder = PackageConfigFileBuilder()
      ..add(name: 'package1', rootFolder: getFolder(packagePath))
      ..add(name: 'datahub', rootFolder: getFolder(datahubPath));

    for (final MapEntry(key: name, value: source) in extraStubs.entries) {
      final root = convertPath('/$name');
      newFile(join(root, 'lib', '$name.dart'), source);
      builder.add(name: name, rootFolder: getFolder(root));
    }

    newPackageConfigJsonFileFromBuilder(packagePath, builder);
    newPubspecYamlFile(packagePath, 'name: package1');
  }

  StreamQueue<protocol.AnalysisErrorsParams> get _analysisErrorsParams =>
      StreamQueue(
        channel.notifications
            .where((n) => n.event == protocol.ANALYSIS_NOTIFICATION_ERRORS)
            .map(protocol.AnalysisErrorsParams.fromNotification)
            .where((p) => p.file == filePath),
      );

  /// Sets the analysis roots and waits for the first batch of diagnostics, so
  /// that fixes and assists are requested against a completed analysis.
  Future<List<protocol.AnalysisError>> _setRoots() async {
    final params = _analysisErrorsParams;

    await Future.wait([
      channel.sendRequest(
        protocol.AnalysisSetContextRootsParams([contextRoot]),
      ),
      channel.sendRequest(
        protocol.AnalysisSetAnalysisRootsParams([contextRoot.root], []),
      ),
    ]);

    return (await params.next).errors;
  }

  /// Writes [content] and returns the diagnostics reported for it.
  ///
  /// Useful for confirming a rule fires inside this harness before asserting
  /// on the fixes it offers.
  Future<List<protocol.AnalysisError>> diagnosticsFor(String content) async {
    newFile(filePath, content);
    return await _setRoots();
  }

  /// Writes [content] to the test file, requests fixes at the first occurrence
  /// of [at], and asserts that applying the fix identified by [fixKindId]
  /// produces [expected].
  Future<void> assertFix(
    String content, {
    required String at,
    required String fixKindId,
    required String expected,
  }) async {
    final offset = _offsetOf(content, at);
    newFile(filePath, content);
    await _setRoots();

    final result = await pluginServer.handleEditGetFixes(
      protocol.EditGetFixesParams(filePath, offset),
    );

    final fixes = [for (final f in result.fixes) ...f.fixes];
    final matching = fixes.where((f) => f.change.id == fixKindId).toList();

    expect(
      matching,
      hasLength(1),
      reason:
          'Expected exactly one "$fixKindId" fix at offset $offset, got: '
          '${fixes.map((f) => f.change.id).toList()}',
    );

    expect(
      protocol.SourceEdit.applySequence(
        content,
        matching.single.change.edits.single.edits,
      ),
      expected,
    );
  }

  /// Asserts that no fix with [fixKindId] is offered at [at].
  Future<void> assertNoFix(
    String content, {
    required String at,
    required String fixKindId,
  }) async {
    final offset = _offsetOf(content, at);
    newFile(filePath, content);
    await _setRoots();

    final result = await pluginServer.handleEditGetFixes(
      protocol.EditGetFixesParams(filePath, offset),
    );

    final fixes = [for (final f in result.fixes) ...f.fixes];
    expect(fixes.where((f) => f.change.id == fixKindId), isEmpty);
  }

  /// Writes [content], requests assists at the first occurrence of [at], and
  /// asserts that applying the assist identified by [assistKindId] produces
  /// [expected].
  Future<void> assertAssist(
    String content, {
    required String at,
    required String assistKindId,
    required String expected,
  }) async {
    final offset = _offsetOf(content, at);
    newFile(filePath, content);
    await _setRoots();

    final response = await channel.sendRequest(
      protocol.EditGetAssistsParams(filePath, offset, 0),
    );
    final result = protocol.EditGetAssistsResult.fromResponse(response);

    final matching = result.assists
        .where((a) => a.change.id == assistKindId)
        .toList();

    expect(
      matching,
      hasLength(1),
      reason:
          'Expected exactly one "$assistKindId" assist at offset $offset, got: '
          '${result.assists.map((a) => a.change.id).toList()}',
    );

    expect(
      protocol.SourceEdit.applySequence(
        content,
        matching.single.change.edits.single.edits,
      ),
      expected,
    );
  }

  /// Asserts that no assist with [assistKindId] is offered at [at].
  Future<void> assertNoAssist(
    String content, {
    required String at,
    required String assistKindId,
  }) async {
    final offset = _offsetOf(content, at);
    newFile(filePath, content);
    await _setRoots();

    final response = await channel.sendRequest(
      protocol.EditGetAssistsParams(filePath, offset, 0),
    );
    final result = protocol.EditGetAssistsResult.fromResponse(response);

    expect(result.assists.where((a) => a.change.id == assistKindId), isEmpty);
  }

  int _offsetOf(String content, String needle) {
    final offset = content.indexOf(needle);
    if (offset < 0) {
      fail('Could not find "$needle" in the test source.');
    }
    return offset;
  }
}

class _FakeChannel implements PluginCommunicationChannel {
  final _completers = <String, Completer<protocol.Response>>{};
  final _notifications = StreamController<protocol.Notification>.broadcast();

  void Function(protocol.Request)? _onRequest;

  int _idCounter = 0;

  Stream<protocol.Notification> get notifications => _notifications.stream;

  @override
  void close() {}

  @override
  void listen(
    void Function(protocol.Request request)? onRequest, {
    void Function()? onDone,
    Function? onError,
    Function? onNotification,
  }) {
    _onRequest = onRequest;
  }

  @override
  void sendNotification(protocol.Notification notification) {
    _notifications.add(notification);
  }

  Future<protocol.Response> sendRequest(protocol.RequestParams params) {
    final onRequest = _onRequest;
    if (onRequest == null) {
      fail('listen has not yet been called on this channel.');
    }

    final request = params.toRequest((_idCounter++).toString());
    final completer = Completer<protocol.Response>();
    _completers[request.id] = completer;
    onRequest(request);
    return completer.future;
  }

  @override
  void sendResponse(protocol.Response response) {
    _completers.remove(response.id)?.complete(response);
  }
}
