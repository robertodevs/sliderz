import 'package:flutter/material.dart';

import 'package:sliderz/common/components/midi_button.dart';
import 'package:sliderz/midi/models/nanokontrol2_mapping.dart';
import 'package:sliderz/theme/app_theme.dart';

class TransportPanel extends StatelessWidget {
  const TransportPanel({super.key, required this.onTransport});

  final ValueChanged<int> onTransport;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTouch.transportPanelWidth,
      padding: const EdgeInsets.all(10),
      decoration: neumorphicDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _NavigationSection(onTransport: onTransport),
            ),
          ),
          const SizedBox(height: 8),
          _TransportSection(onTransport: onTransport),
        ],
      ),
    );
  }
}

class _NavigationSection extends StatelessWidget {
  const _NavigationSection({required this.onTransport});

  final ValueChanged<int> onTransport;

  static const _arrowButtonSize = AppTouch.transportButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TRACK', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        Row(
          children: [
            MidiButton(
              icon: Icons.chevron_left,
              size: _arrowButtonSize,
              glowWhenActive: false,
              onPressed: () => onTransport(NanoKontrol2Mapping.trackLeft),
              onReleased: () {},
            ),
            const SizedBox(width: 4),
            MidiButton(
              icon: Icons.chevron_right,
              size: _arrowButtonSize,
              glowWhenActive: false,
              onPressed: () => onTransport(NanoKontrol2Mapping.trackRight),
              onReleased: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('MARKER', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            MidiButton(
              label: 'SET',
              size: _arrowButtonSize,
              accentColor: AppColors.accent,
              onPressed: () => onTransport(NanoKontrol2Mapping.markerSet),
              onReleased: () {},
            ),
            MidiButton(
              icon: Icons.chevron_left,
              size: _arrowButtonSize,
              glowWhenActive: false,
              onPressed: () => onTransport(NanoKontrol2Mapping.markerLeft),
              onReleased: () {},
            ),
            MidiButton(
              icon: Icons.chevron_right,
              size: _arrowButtonSize,
              glowWhenActive: false,
              onPressed: () => onTransport(NanoKontrol2Mapping.markerRight),
              onReleased: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('CYCLE', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        MidiButton(
          icon: Icons.loop,
          size: _arrowButtonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.cycle),
          onReleased: () {},
        ),
      ],
    );
  }
}

class _TransportSection extends StatelessWidget {
  const _TransportSection({required this.onTransport});

  final ValueChanged<int> onTransport;

  static const _transportButtonSize = AppTouch.transportButton;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        MidiButton(
          icon: Icons.fast_rewind,
          size: _transportButtonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.rewind),
          onReleased: () {},
        ),
        MidiButton(
          icon: Icons.fast_forward,
          size: _transportButtonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.fastForward),
          onReleased: () {},
        ),
        MidiButton(
          icon: Icons.stop,
          size: _transportButtonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.stop),
          onReleased: () {},
        ),
        MidiButton(
          icon: Icons.play_arrow,
          size: _transportButtonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.play),
          onReleased: () {},
        ),
        MidiButton(
          icon: Icons.fiber_manual_record,
          size: _transportButtonSize,
          accentColor: const Color(0xFFEF4444),
          onPressed: () => onTransport(NanoKontrol2Mapping.recordTransport),
          onReleased: () {},
        ),
      ],
    );
  }
}
