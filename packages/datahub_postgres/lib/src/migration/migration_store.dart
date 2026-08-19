import 'dart:io';

import 'package:path/path.dart' as p;

import 'migration.dart';

/// Reads and writes the migration files of a project.
///
/// The store is deliberately strict: a gap, a duplicate or an unparseable file
/// is an error rather than something to skip, because every one of those means
/// the replayed schema would no longer describe what a database actually got.
class MigrationStore {
  static final _fileName = RegExp(r'^(\d+)_([a-z0-9]+(?:_[a-z0-9]+)*)\.sql$');

  final Directory directory;

  const MigrationStore(this.directory);

  MigrationStore.ofPath(String path) : this(Directory(path));

  /// Loads all migrations, ordered by version.
  Future<List<MigrationFile>> load() async {
    if (!await directory.exists()) {
      return const [];
    }

    final files = <MigrationFile>[];
    await for (final entry in directory.list()) {
      if (entry is! File || !entry.path.endsWith('.sql')) {
        continue;
      }

      final fileName = p.basename(entry.path);
      final match = _fileName.firstMatch(fileName);
      if (match == null) {
        throw MigrationFormatException(
          'File name does not match "<version>_<name>.sql".',
          fileName,
        );
      }

      final content = await entry.readAsString();
      final migration = Migration.parse(content, source: fileName);

      if (migration.version != int.parse(match.group(1)!)) {
        throw MigrationFormatException(
          'File name declares version ${match.group(1)} but the header '
          'declares ${migration.version}.',
          fileName,
        );
      }

      if (migration.name != match.group(2)) {
        throw MigrationFormatException(
          'File name declares "${match.group(2)}" but the header declares '
          '"${migration.name}".',
          fileName,
        );
      }

      files.add(
        MigrationFile(
          migration: migration,
          file: entry,
          checksum: Migration.checksumOf(content),
        ),
      );
    }

    files.sort((a, b) => a.migration.version.compareTo(b.migration.version));

    for (final (index, file) in files.indexed) {
      if (file.migration.version != index + 1) {
        throw MigrationFormatException(
          'Expected version ${index + 1} but found '
          '${file.migration.version}. Migration versions have to start at 1 '
          'and increase without gaps.',
          file.migration.fileName,
        );
      }
    }

    return files;
  }

  /// Writes [migration] into [directory], creating it if needed.
  Future<File> write(Migration migration) async {
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, migration.fileName));
    if (await file.exists()) {
      throw MigrationFormatException(
        'Migration file already exists.',
        migration.fileName,
      );
    }

    await file.writeAsString(migration.render());
    return file;
  }

  /// Normalizes a user supplied migration name into `lower_snake_case`.
  static String normalizeName(String name) {
    final normalized = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (normalized.isEmpty) {
      throw MigrationFormatException(
        'Migration name "$name" contains no usable characters.',
      );
    }

    return normalized;
  }
}

/// A [Migration] together with the file it was read from.
class MigrationFile {
  final Migration migration;
  final File file;

  /// The checksum of the file content as it was on disk.
  final String checksum;

  const MigrationFile({
    required this.migration,
    required this.file,
    required this.checksum,
  });
}
