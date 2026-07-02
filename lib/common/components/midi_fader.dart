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

  void _updateValue(double nextValue) {
    _haptics.onValueChanged(nextValue);
    widget.onChanged(nextValue);
  }

  void _beginInteraction() {
    MidiHaptics.dragStart();
    _haptics.onValueChanged(widget.value);
  }

  void _endInteraction() => _haptics.reset();

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
                    if (contentWidth >= MidiFader.laneWidth) const SizedBox(width: 8),
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
                              decoration: BoxDecoration(
                                color: AppColors.border.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: (AppTouch.faderCapWidth -
                                    AppTouch.faderTrackWidth) /
                                2,
                            child: Container(
                              width: AppTouch.faderTrackWidth,
                              height: fillHeight,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.glow(
                                      widget.accentColor,
                                      0.7,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: top,
                            child: Container(
                              width: AppTouch.faderCapWidth,
                              height: capHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2836),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: widget.accentColor.withValues(
                                    alpha: 0.7,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.glow(
                                      widget.accentColor,
                                      0.35,
                                    ),
                                    blurRadius: 6,
                                  ),
                                  const BoxShadow(
                                    color: Color(0x88000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: AppTouch.faderCapWidth * 0.5,
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    color: widget.accentColor,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
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
