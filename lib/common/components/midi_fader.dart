import 'package:flutter/material.dart';

import 'package:sliderz/common/utils/midi_haptics.dart';
import 'package:sliderz/theme/app_theme.dart';

class MidiFader extends StatefulWidget {
  const MidiFader({
    super.key,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    this.height = 120,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final Color accentColor;
  final double height;

  static const double laneWidth = AppTouch.faderLaneWidth;

  @override
  State<MidiFader> createState() => _MidiFaderState();
}

class _MidiFaderState extends State<MidiFader> {
  final ValueStepHaptics _haptics = ValueStepHaptics();
  bool _dragging = false;

  void _updateValue(double nextValue) {
    _haptics.onValueChanged(nextValue);
    widget.onChanged(nextValue);
  }

  void _beginInteraction() {
    setState(() => _dragging = true);
    MidiHaptics.dragStart();
    _haptics.onValueChanged(widget.value);
  }

  void _endInteraction() {
    if (_dragging) setState(() => _dragging = false);
    _haptics.reset();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.height;
        final capHeight = AppTouch.faderCapHeight;
        final travel = (h - capHeight).clamp(1.0, double.infinity);
        final top = (1 - widget.value) * travel;
        final fillHeight = (h - top - capHeight / 2).clamp(0.0, h);
        final touchWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MidiFader.laneWidth;
        final contentWidth = touchWidth < MidiFader.laneWidth
            ? touchWidth
            : MidiFader.laneWidth;
        final trackOffset =
            (AppTouch.faderCapWidth - AppTouch.faderTrackWidth) / 2;

        void updateFromDy(double localY) {
          _updateValue(
            (1 - (localY - capHeight / 2) / travel).clamp(0.0, 1.0),
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) => _beginInteraction(),
          onVerticalDragUpdate: (details) =>
              updateFromDy(details.localPosition.dy),
          onVerticalDragEnd: (_) => _endInteraction(),
          onVerticalDragCancel: _endInteraction,
          onTapDown: (details) {
            _beginInteraction();
            updateFromDy(details.localPosition.dy);
          },
          onTapUp: (_) => _endInteraction(),
          onTapCancel: _endInteraction,
          child: SizedBox(
            width: touchWidth,
            height: h,
            child: Center(
              child: SizedBox(
                width: contentWidth,
                height: h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (contentWidth >= MidiFader.laneWidth)
                      _FaderScale(height: h, accentColor: widget.accentColor),
                    if (contentWidth >= MidiFader.laneWidth)
                      const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: AppTouch.faderTrackWidth,
                              height: h,
                              decoration: faderTrackDecoration(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: trackOffset,
                            child: Container(
                              width: AppTouch.faderTrackWidth,
                              height: fillHeight,
                              decoration: faderFillDecoration(
                                accent: widget.accentColor,
                              ),
                            ),
                          ),
                          Positioned(
                            top: top,
                            child: _FaderCap(
                              accentColor: widget.accentColor,
                              pressed: _dragging,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FaderCap extends StatelessWidget {
  const _FaderCap({
    required this.accentColor,
    required this.pressed,
  });

  final Color accentColor;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final capWidth = AppTouch.faderCapWidth;
    final capHeight = AppTouch.faderCapHeight;
    final grooveWidth = capWidth * 0.56;
    final grooveHeight = capHeight * 0.22;

    return AnimatedContainer(
      duration: pressed ? Duration.zero : const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      width: capWidth,
      height: capHeight,
      decoration: faderCapDecoration(
        accent: accentColor,
        pressed: pressed,
      ),
      child: Center(
        child: Container(
          width: grooveWidth,
          height: grooveHeight,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: faderCapGrooveDecoration(accent: accentColor),
          child: Center(
            child: Container(
              width: grooveWidth * 0.72,
              height: 2.5,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glow(accentColor, 0.8),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaderScale extends StatelessWidget {
  const _FaderScale({required this.height, required this.accentColor});

  final double height;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    const labels = ['100', '50', '0'];
    return SizedBox(
      width: AppTouch.faderScaleWidth,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels
            .map(
              (label) => Text(
                label,
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.75),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
