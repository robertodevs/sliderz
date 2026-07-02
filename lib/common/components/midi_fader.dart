import 'package:flutter/material.dart';

import 'package:sliderz/theme/app_theme.dart';

class MidiFader extends StatelessWidget {
  const MidiFader({
    super.key,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    this.width = 36,
    this.height = 120,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final Color accentColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h =
            constraints.maxHeight.isFinite ? constraints.maxHeight : height;
        final capHeight = h * 0.11;
        final travel = h - capHeight;
        final top = (1 - value) * travel;
        final fillHeight = h - top - capHeight / 2;

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            final localY = details.localPosition.dy - capHeight / 2;
            onChanged((1 - localY / travel).clamp(0.0, 1.0));
          },
          onTapDown: (details) {
            final localY = details.localPosition.dy - capHeight / 2;
            onChanged((1 - localY / travel).clamp(0.0, 1.0));
          },
          child: SizedBox(
            width: width + 18,
            height: h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FaderScale(height: h, accentColor: accentColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: 3,
                        height: h,
                        decoration: BoxDecoration(
                          color: AppColors.border.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 3,
                          height: fillHeight.clamp(0, h),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glow(accentColor, 0.7),
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
                          width: width,
                          height: capHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2836),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glow(accentColor, 0.35),
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
                              width: width * 0.55,
                              height: 2,
                              decoration: BoxDecoration(
                                color: accentColor,
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
      width: 14,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels
            .map(
              (label) => Text(
                label,
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.7),
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
