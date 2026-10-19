import 'package:datahub_aperture_frontend/models/file_value.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Saves a file on the device. Returns false if the user cancelled.
typedef FileSaver = Future<bool> Function(FileValue file);

/// Saves [file] as a download in web browsers, through a save dialog in
/// desktop and mobile apps.
Future<bool> saveFile(FileValue file) async {
  final path = await FilePicker.saveFile(fileName: file.name, bytes: file.data);
  // Browsers download the file without telling where to.
  return kIsWeb || path != null;
}

/// The file name of a content-disposition header, preferring the UTF-8 one
/// (RFC 6266).
String? dispositionFileName(String disposition) {
  final encoded = RegExp(
    r"filename\*\s*=\s*UTF-8''([^;\s]+)",
    caseSensitive: false,
  ).firstMatch(disposition)?[1];
  if (encoded != null) {
    try {
      return Uri.decodeComponent(encoded);
    } on ArgumentError catch (_) {
      // Falls back to the plain file name.
    }
  }

  final match = RegExp(
    r'filename\s*=\s*(?:"((?:[^"\\]|\\.)*)"|([^;\s]+))',
    caseSensitive: false,
  ).firstMatch(disposition);
  return match?[1]?.replaceAllMapped(RegExp(r'\\(.)'), (m) => m[1]!) ??
      match?[2];
}
