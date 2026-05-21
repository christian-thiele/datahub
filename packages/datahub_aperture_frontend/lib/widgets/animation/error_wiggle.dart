import 'dart:math';

import 'package:flutter/material.dart';

class ErrorWiggle extends StatefulWidget {
  final AnimationController controller;
  final Widget child;
  final double amplitude;
  final int frequency;

  const ErrorWiggle({
    super.key,
    required this.child,
    required this.controller,
    this.amplitude = 4,
    this.frequency = 8,
  });

  @override
  State<ErrorWiggle> createState() => _ErrorWiggleState();
}

class _ErrorWiggleState extends State<ErrorWiggle> {
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animation = CurvedAnimation(
      parent: widget.controller,
      curve: Curves.linear,
    ).drive(Tween(begin: 0, end: widget.frequency.toDouble()));

    _animation.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translationValues(
        sin(pi * _animation.value) *
            (1 - _animation.value / widget.frequency) *
            widget.amplitude,
        0,
        0,
      ),
      child: widget.child,
    );
  }
}
