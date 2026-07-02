import 'package:flutter/material.dart';

import 'package:sliderz/controller/components/network_midi_sheet.dart';
import 'package:sliderz/midi/services/midi_service.dart';
import 'package:sliderz/theme/app_theme.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.midiService});

  final MidiService midiService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          Expanded(child: _StatusIndicators(midiService: midiService)),
          const _BrandTitle(),
          Expanded(child: _StatusActions(midiService: midiService)),
        ],
      ),
    );
  }
}

class _StatusIndicators extends StatelessWidget {
  const _StatusIndicators({required this.midiService});

  final MidiService midiService;

  @override
  Widget build(BuildContext context) {
    final ready = midiService.isReady;
    final networkOn = midiService.networkEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusLine(
          color: ready ? AppColors.success : const Color(0xFFEF4444),
          label: ready ? 'MIDI local activo' : 'MIDI no disponible',
        ),
        if (midiService.networkSupported) ...[
          const SizedBox(height: 2),
          _StatusLine(
            icon: networkOn ? Icons.wifi : Icons.wifi_off,
            color: networkOn ? AppColors.success : AppColors.label,
            label: networkOn
                ? 'MIDI por red activo'
                : 'MIDI por red desactivado',
          ),
        ],
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 10, color: color)
        else
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.labelBright.withValues(alpha: 0.85),
                  fontSize: 8,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'S L I D E R Z',
      style: TextStyle(
        color: AppColors.labelBright,
        fontSize: 15,
        fontWeight: FontWeight.w300,
        letterSpacing: 6,
      ),
    );
  }
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.midiService});

  final MidiService midiService;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ActionChip(
          icon: Icons.tune,
          label: 'CH ${midiService.channel + 1}',
          onTap: () => _showChannelMenu(context),
        ),
        const SizedBox(width: 6),
        _IconChip(
          icon: Icons.settings_outlined,
          onTap: () => NetworkMidiSheet.show(context, midiService),
        ),
      ],
    );
  }

  void _showChannelMenu(BuildContext context) {
    showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
      color: AppColors.panelElevated,
      items: List.generate(
        16,
        (index) => PopupMenuItem(
          value: index,
          child: Text(
            'Canal ${index + 1}',
            style: const TextStyle(color: AppColors.labelBright, fontSize: 13),
          ),
        ),
      ),
    ).then((channel) {
      if (channel != null) midiService.setChannel(channel);
    });
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: neumorphicDecoration(radius: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.label),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.labelBright,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: neumorphicDecoration(radius: 8),
        child: Icon(icon, size: 15, color: AppColors.label),
      ),
    );
  }
}
