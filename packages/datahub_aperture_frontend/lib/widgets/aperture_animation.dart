import 'dart:math';

import 'package:boost/boost.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApertureSpinner extends StatefulWidget {
  final Color? color;

  const ApertureSpinner({super.key, this.color});

  @override
  State<ApertureSpinner> createState() => _ApertureSpinnerState();
}

class _ApertureSpinnerState extends State<ApertureSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      value: 0.35,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          foregroundPainter: _Painter(
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            animation: _controller,
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final Color color;
  final Animation<double> animation;

  _Painter({required this.color, required this.animation})
    : super(repaint: animation);

  late final _fillPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  final _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.05
    ..blendMode = BlendMode.clear;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.scale(size.shortestSide / 2);
    canvas.translate(1, 1);
    canvas.scale(0.8);

    final holeAnimation = padDown(animation.value, 0.1, 0);

    final double k = 0.7; // modulation depth [0,1)
    final double turnsPerCycle = 3; // rotations per controller cycle
    const twoPi = 2 * pi;
    final rotation =
        twoPi *
        turnsPerCycle *
        (animation.value - (k / twoPi) * sin(twoPi * animation.value));

    final hole = sin(holeAnimation * 2 * pi - (pi / 2)) / 2 + 0.5;

    canvas.rotate(rotation);

    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(i * pi / 3);
      drawBlade(canvas, hole);
      canvas.restore();
    }

    canvas.restore();
  }

  void drawBlade(Canvas canvas, double holeSize) {
    final path = Path();
    path.moveTo(1, 0);
    path.arcToPoint(Offset(-1, 0), radius: Radius.elliptical(1, 1));
    path.arcToPoint(
      Offset(1, 0),
      radius: Radius.elliptical(1.05, 0.55 + holeSize * 0.45),
      clockwise: false,
    );
    path.close();

    final rotated = Path.from(
      path,
    ).transform(Matrix4.rotationZ(pi / 3).storage);

    final diff = Path.combine(PathOperation.difference, path, rotated);

    canvas.save();
    canvas.drawPath(diff, _fillPaint);
    canvas.drawPath(diff, _outlinePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  static double padDown(double value, double padLeft, [double? padRight]) {
    padRight ??= padLeft;
    final fac = 1 / (1 - padLeft - padRight);
    return clamp((value - padLeft) * fac, 0, 1);
  }
}

class ApertureLogo extends StatelessWidget {
  final bool withText;
  final Color? color;
  final double size;

  const ApertureLogo({
    super.key,
    this.color,
    this.withText = true,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    return DefaultTextStyle.merge(
      style: GoogleFonts.poppins(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              foregroundPainter: _LogoPainter(color: effectiveColor),
              isComplex: false,
              willChange: false,
            ),
          ),
          if (withText)
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Text(
                'Aperture',
                style: TextStyle(
                  fontSize: size * 0.5625,
                  fontWeight: FontWeight.bold,
                  color: effectiveColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  late final _fillPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  final _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.05
    ..blendMode = BlendMode.clear;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.scale(size.shortestSide / 2);
    canvas.translate(1, 1);
    canvas.scale(0.8);

    canvas.rotate(0.15);

    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(i * pi / 3);
      drawBlade(canvas);
      canvas.restore();
    }

    canvas.restore();
  }

  void drawBlade(Canvas canvas) {
    final path = Path();
    path.moveTo(1, 0);
    path.arcToPoint(Offset(-1, 0), radius: Radius.elliptical(1, 1));
    path.arcToPoint(
      Offset(1, 0),
      radius: Radius.elliptical(1.05, 0.55),
      clockwise: false,
    );
    path.close();

    final rotated = Path.from(
      path,
    ).transform(Matrix4.rotationZ(pi / 3).storage);

    final diff = Path.combine(PathOperation.difference, path, rotated);

    canvas.save();
    canvas.drawPath(diff, _fillPaint);
    canvas.drawPath(diff, _outlinePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
