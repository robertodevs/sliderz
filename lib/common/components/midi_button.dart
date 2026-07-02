import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sliderz/common/utils/midi_haptics.dart';
import 'package:sliderz/theme/app_theme.dart';

class MidiButton extends StatefulWidget {
  const MidiButton({
    super.key,
    this.label = '',
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
  static const _minPressDuration = Duration(milliseconds: 120);

  bool _pressed = false;
  DateTime? _pressStartedAt;
  Timer? _releaseHoldTimer;

  @override
  void dispose() {
    _releaseHoldTimer?.cancel();
    super.dispose();
  }

  void _pressDown() {
    _releaseHoldTimer?.cancel();
    _pressStartedAt = DateTime.now();
    setState(() => _pressed = true);

    if (!widget.momentary) return;

    MidiHaptics.buttonPress();
    widget.onPressed!();
  }

  void _pressUp({required bool invokeMomentaryRelease}) {
    if (widget.momentary && invokeMomentaryRelease) {
      widget.onReleased!();
    }
    _scheduleRelease();
  }

  void _pressCancel({required bool invokeMomentaryRelease}) {
    if (widget.momentary && invokeMomentaryRelease) {
      widget.onReleased!();
    }
    _scheduleRelease();
  }

  void _scheduleRelease() {
    final startedAt = _pressStartedAt;
    _pressStartedAt = null;
    if (startedAt == null) {
      setState(() => _pressed = false);
      return;
    }

    final held = DateTime.now().difference(startedAt);
    final remaining = _minPressDuration - held;
    if (!remaining.isNegative) {
      _releaseHoldTimer = Timer(remaining, _clearPressed);
      return;
    }

    setState(() => _pressed = false);
  }

  void _clearPressed() {
    if (!mounted) return;
    setState(() => _pressed = false);
  }

  Color _backgroundColor(Color accent) {
    if (widget.active) return accent.withValues(alpha: 0.28);
    if (_pressed) return accent.withValues(alpha: 0.22);
    return AppColors.panelElevated;
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.accent;
    final lit = widget.active || _pressed;
    final showGlow =
        (widget.active && widget.glowWhenActive) || _pressed;
    final hitSize = widget.size < AppTouch.minTarget
        ? AppTouch.minTarget
        : widget.size;
    final releaseDuration = _pressed
        ? Duration.zero
        : const Duration(milliseconds: 100);

    return SizedBox(
      width: hitSize,
      height: hitSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressDown(),
        onTap: widget.momentary
            ? null
            : () {
                MidiHaptics.buttonPress();
                widget.onTap!();
              },
        onTapUp: (_) => _pressUp(invokeMomentaryRelease: true),
        onTapCancel: () => _pressCancel(invokeMomentaryRelease: true),
        child: Center(
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: releaseDuration,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: releaseDuration,
              curve: Curves.easeOut,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _backgroundColor(accent),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: lit ? accent : AppColors.border,
                  width: widget.active ? 2 : (lit ? 2 : 1),
                ),
                boxShadow: showGlow
                    ? [
                        BoxShadow(
                          color: AppColors.glow(accent, _pressed ? 0.55 : 0.45),
                          blurRadius: _pressed ? 14 : 12,
                          spreadRadius: _pressed ? 2 : 1,
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
      ),
    );
  }
}
