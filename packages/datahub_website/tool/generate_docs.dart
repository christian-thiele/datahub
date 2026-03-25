import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final websiteRoot = Directory.current.path;
  final projectRoot = p.normalize(p.join(websiteRoot, '../../'));
  final apiDocsDir = Directory(p.join(websiteRoot, 'content/docs/api'));
  final packagesDir = Directory(p.join(projectRoot, 'packages'));

  if (!apiDocsDir.existsSync()) {
    apiDocsDir.createSync(recursive: true);
  }

  print('Generating API documentation from packages...');

  final packages = packagesDir.listSync().whereType<Directory>();

  for (final packageDir in packages) {
    final packageName = p.basename(packageDir.path);
    if (packageName == 'datahub_website') continue;

    print('Processing package: $packageName');

    // 1. Copy README.md as index.md for the package
    final readme = File(p.join(packageDir.path, 'README.md'));
    if (readme.existsSync()) {
      print('  Found README.md, copying as index.md');
      final packageDocDir = Directory(p.join(apiDocsDir.path, packageName));
      if (!packageDocDir.existsSync()) {
        packageDocDir.createSync();
      }
      readme.copySync(p.join(packageDocDir.path, 'index.md'));
    } else {
      print('  README.md not found');
    }
  }

  print('Documentation generation complete!');
}
