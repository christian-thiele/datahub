import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class WidgetSaver extends StatefulWidget {
  final WidgetTester tester;
  final File file;
  final Widget child;

  const WidgetSaver({
    super.key,
    required this.child,
    required this.file,
    required this.tester,
  });

  @override
  WidgetSaverState createState() => WidgetSaverState();

  static Future<void> saveWidget(
    WidgetTester tester,
    Widget widget,
    File file,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Center(
            child: WidgetSaver(tester: tester, file: file, child: widget),
          ),
        ),
        theme: ApertureThemeData.defaultTheme,
      ),
    );
  }
}

class WidgetSaverState extends State<WidgetSaver> {
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.tester.runAsync(_capturePng);
    });
  }

  Future<void> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    widget.file.writeAsBytesSync(pngBytes);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: globalKey, child: widget.child);
  }
}

void main() {
  testWidgets('Render logo with text', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: true),
      File('logo_text.png'),
    );
  });

  testWidgets('Render Logo', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: false),
      File('logo.png'),
    );
  });

  testWidgets('Render logo with text white', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: true, color: Colors.white),
      File('logo_text_white.png'),
    );
  });

  testWidgets('Render Logo white', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: false, color: Colors.white),
      File('logo_white.png'),
    );
  });

  testWidgets('Render logo with text x4', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: true, size: 48 * 4),
      File('logo_text_x4.png'),
    );
  });

  testWidgets('Render Logo x4', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: false, size: 48 * 4),
      File('logo_x4.png'),
    );
  });

  testWidgets('Render logo with text white x4', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: true, color: Colors.white, size: 48 * 4),
      File('logo_text_white_x4.png'),
    );
  });

  testWidgets('Render Logo white x4', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: false, color: Colors.white, size: 48 * 4),
      File('logo_white_x4.png'),
    );
  });

  testWidgets('Render logo with text color x4', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: true, color: Color(0xff295bf0), size: 48 * 4),
      File('logo_text_color_x4.png'),
    );
  });

  testWidgets('Render Logo color x4', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: false, color: Color(0xff295bf0), size: 48 * 4),
      File('logo_color_x4.png'),
    );
  });

  testWidgets('Render Logo color x12', (tester) async {
    await WidgetSaver.saveWidget(
      tester,
      ApertureLogo(withText: false, color: Color(0xff295bf0), size: 48 * 12),
      File('logo_color_x12.png'),
    );
  });
}
