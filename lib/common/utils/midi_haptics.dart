import 'package:flutter/services.dart';

class MidiHaptics {
  static void buttonPress() => HapticFeedback.mediumImpact();

  static void dragStart() => HapticFeedback.lightImpact();
}

class ValueStepHaptics {
  ValueStepHaptics({this.steps = 24});

  final int steps;
  int? _lastStep;

  void onValueChanged(double value) {
    final step = (value.clamp(0.0, 1.0) * steps).round();
    if (_lastStep == step) return;
    _lastStep = step;
    HapticFeedback.selectionClick();
  }

  void reset() => _lastStep = null;
}
