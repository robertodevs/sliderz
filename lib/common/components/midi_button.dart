import 'package:flutter/material.dart';

import 'package:sliderz/theme/app_theme.dart';

class MidiButton extends StatefulWidget {
  const MidiButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.onReleased,
    this.icon,
    this.active = false,
    this.size = 28,
    this.accentColor,
    this.glowWhenActive = true,
  });

  final String label;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final IconData? icon;
  final bool active;
  final double size;
  final Color? accentColor;
  final bool glowWhenActive;

  @override
  State<MidiButton> createState() => _MidiButtonState();
}

class _MidiButtonState extends State<MidiButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.accent;
    final lit = widget.active || _pressed;
    final showGlow = lit && widget.glowWhenActive;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onPressed();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onReleased();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        widget.onReleased();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.panelElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: showGlow ? accent : AppColors.border,
            width: showGlow ? 1.5 : 1,
          ),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: AppColors.glow(accent, 0.45),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  const BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: widget.icon != null
            ? Icon(
                widget.icon,
                size: widget.size * 0.42,
                color: lit ? accent : AppColors.label,
              )
            : Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: lit ? accent : AppColors.labelBright,
                    fontSize: widget.size * 0.34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
      ),
    );
  }
}
