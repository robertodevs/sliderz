import 'package:flutter/material.dart';

import 'package:sliderz/theme/app_theme.dart';

class MidiButton extends StatefulWidget {
  const MidiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onReleased,
    this.onTap,
    this.momentary = true,
    this.icon,
    this.active = false,
    this.size = AppTouch.channelButton,
    this.accentColor,
    this.glowWhenActive = true,
  }) : assert(
          momentary
              ? onPressed != null && onReleased != null
              : onTap != null,
          'Momentary buttons need onPressed/onReleased; toggle buttons need onTap.',
        );

  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;
  final VoidCallback? onTap;
  final bool momentary;
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
    final showGlow = (widget.active && widget.glowWhenActive) ||
        (_pressed && widget.momentary);
    final hitSize = widget.size < AppTouch.minTarget
        ? AppTouch.minTarget
        : widget.size;

    return SizedBox(
      width: hitSize,
      height: hitSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.momentary ? null : widget.onTap,
        onTapDown: widget.momentary
            ? (_) {
                setState(() => _pressed = true);
                widget.onPressed!();
              }
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.momentary
            ? (_) {
                setState(() => _pressed = false);
                widget.onReleased!();
              }
            : (_) => setState(() => _pressed = false),
        onTapCancel: widget.momentary
            ? () {
                setState(() => _pressed = false);
                widget.onReleased!();
              }
            : () => setState(() => _pressed = false),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.active
                  ? accent.withValues(alpha: 0.28)
                  : AppColors.panelElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: lit ? accent : AppColors.border,
                width: widget.active ? 2 : (lit ? 1.5 : 1),
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
        ),
      ),
    );
  }
}
