import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sliderz/theme/app_theme.dart';

class MidiKnob extends StatefulWidget {
  const MidiKnob({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 44,
    required this.accentColor,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double size;
  final Color accentColor;

  @override
  State<MidiKnob> createState() => _MidiKnobState();
}

class _MidiKnobState extends State<MidiKnob> {
  double? _startValue;
  double? _startDy;

  void _handleDrag(DragUpdateDetails details) {
    final startValue = _startValue ?? widget.value;
    final startDy = _startDy ?? details.localPosition.dy;
    final delta = (startDy - details.localPosition.dy) / 120;
    widget.onChanged((startValue + delta).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        _startValue = widget.value;
        _startDy = details.localPosition.dy;
      },
      onVerticalDragUpdate: _handleDrag,
      onVerticalDragEnd: (_) {
        _startValue = null;
        _startDy = null;
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _KnobPainter(
            value: widget.value,
            accentColor: widget.accentColor,
          ),
        ),
      ),
    );
  }
}

class _KnobPainter extends CustomPainter {
  _KnobPainter({required this.value, required this.accentColor});

  final double value;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angle = -math.pi * 0.75 + value * math.pi * 1.5;

    final glowPaint = Paint()
      ..color = AppColors.glow(accentColor, 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius - 1, glowPaint);

    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(center, radius - 4, Paint()..color = AppColors.knobFace);

    canvas.drawCircle(
      center,
      radius - 4,
      Paint()
        ..color = AppColors.border.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final indicatorEnd = Offset(
      center.dx + math.cos(angle) * (radius - 10),
      center.dy + math.sin(angle) * (radius - 10),
    );
    canvas.drawLine(
      center,
      indicatorEnd,
      Paint()
        ..color = accentColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _KnobPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.accentColor != accentColor;
}
