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
      width: 136,
      padding: const EdgeInsets.all(10),
      decoration: neumorphicDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: _NavigationSection(onTransport: onTransport),
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: _TransportSection(onTransport: onTransport),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationSection extends StatelessWidget {
  const _NavigationSection({required this.onTransport});

  final ValueChanged<int> onTransport;

  static const _buttonSize = 30.0;

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
              label: '◀',
              size: _buttonSize,
              glowWhenActive: false,
              onPressed: () => onTransport(NanoKontrol2Mapping.trackLeft),
              onReleased: () {},
            ),
            const SizedBox(width: 6),
            MidiButton(
              label: '▶',
              size: _buttonSize,
              glowWhenActive: false,
              onPressed: () => onTransport(NanoKontrol2Mapping.trackRight),
              onReleased: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('MARKER', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        Row(
          children: [
            MidiButton(
              label: 'SET',
              size: _buttonSize,
              accentColor: AppColors.accent,
              onPressed: () => onTransport(NanoKontrol2Mapping.markerSet),
              onReleased: () {},
            ),
            const SizedBox(width: 6),
            MidiButton(
              label: '◀',
              size: _buttonSize,
              glowWhenActive: false,
              onPressed: () => onTransport(NanoKontrol2Mapping.markerLeft),
              onReleased: () {},
            ),
            const SizedBox(width: 6),
            MidiButton(
              label: '▶',
              size: _buttonSize,
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
          label: '↻',
          size: _buttonSize,
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

  static const _buttonSize = 34.0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        MidiButton(
          label: '⏮',
          size: _buttonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.rewind),
          onReleased: () {},
        ),
        MidiButton(
          label: '⏭',
          size: _buttonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.fastForward),
          onReleased: () {},
        ),
        MidiButton(
          label: '⏹',
          size: _buttonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.stop),
          onReleased: () {},
        ),
        MidiButton(
          label: '▶',
          size: _buttonSize,
          glowWhenActive: false,
          onPressed: () => onTransport(NanoKontrol2Mapping.play),
          onReleased: () {},
        ),
        MidiButton(
          label: '●',
          size: _buttonSize,
          accentColor: const Color(0xFFEF4444),
          onPressed: () => onTransport(NanoKontrol2Mapping.recordTransport),
          onReleased: () {},
        ),
      ],
    );
  }
}
