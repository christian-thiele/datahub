import 'package:datahub_aperture_frontend/utils/file_saver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dispositionFileName', () {
    test('prefers the UTF-8 file name', () {
      expect(
        dispositionFileName(
          'attachment; filename="_bersicht.csv"; '
          "filename*=UTF-8''%C3%9Cbersicht%20%22Q3%22.csv",
        ),
        'Übersicht "Q3".csv',
      );
    });

    test('reads quoted file names', () {
      expect(
        dispositionFileName(r'attachment; filename="a \"b\".pdf"'),
        'a "b".pdf',
      );
    });

    test('reads unquoted file names', () {
      expect(
        dispositionFileName('attachment;filename=report.pdf'),
        'report.pdf',
      );
    });

    test('is null without a file name', () {
      expect(dispositionFileName('attachment'), isNull);
    });
  });
}
