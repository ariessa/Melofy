import 'package:flutter/material.dart';
import 'package:melofy/miscellaneous.dart';
import 'dart:math' as math;

class CircleThumbShape extends SliderComponentShape {
  /// Create a slider thumb that draws a circle.
  const CircleThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.elevation = 1.0,
    this.pressedElevation = 6.0,
  });

  final double enabledThumbRadius;
  final double disabledThumbRadius;
  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;
  final double elevation;
  final double pressedElevation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
     Animation<double> activationAnimation,
     Animation<double> enableAnimation,
     bool isDiscrete,
     TextPainter labelPainter,
     RenderBox parentBox,
     SliderThemeData sliderTheme,
     TextDirection textDirection,
     double value,
     double textScaleFactor,
     Size sizeWithOverflow,
  }) {
    assert(context != null);
    assert(center != null);
    assert(enableAnimation != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );

    final double radius = radiusTween.evaluate(enableAnimation);

    final Tween<double> elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );

    final double evaluatedElevation = elevationTween.evaluate(activationAnimation);
    final Path path = Path()
      ..addArc(Rect.fromCenter(center: center, width: 2 * radius, height: 2 * radius), 0, math.pi * 2);
    canvas.drawShadow(path, Colors.black, evaluatedElevation, true);

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = ColourConfig().dodgerBlue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      center,
      radius,
      fillPaint,
    );

    canvas.drawCircle(
      center,
      radius,
      borderPaint,
    );
  }
}