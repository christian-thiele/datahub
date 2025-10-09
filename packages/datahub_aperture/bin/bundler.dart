import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length < 2 || args.length > 3) {
    print('Usage: bundler <source directory> <output file> [bundleIdentifier]');
    return;
  }

  final path = Directory(args.first);
  final destination = File(args[1]);
  final bundleData = <String, String>{};

  for (final file in path.listSync(recursive: true).whereType<File>()) {
    var relativePath = file.path.substring(path.path.length);
    if (relativePath.startsWith('/')) {
      relativePath = relativePath.substring(1);
    }
    print('Bundling file: $relativePath');
    bundleData[relativePath] = base64Encode(file.readAsBytesSync());
  }

  final bundleIdentifier = args.length > 2 ? args[2] : 'bundle';

  final sink = destination.openWrite();
  sink.writeln('import \'dart:typed_data\';');
  sink.writeln('import \'dart:convert\';');

  sink.writeln(
      'Uint8List? $bundleIdentifier(String path) => switch (_$bundleIdentifier[path]) { String encoded => base64Decode(encoded), _ => null, };');
  sink.writeln(
    'const _$bundleIdentifier = ${jsonEncode(bundleData)};',
  );
  sink.close();
}
