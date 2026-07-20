import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'package:sliderz/midi/services/midi_service.dart';
import 'package:sliderz/theme/app_theme.dart';

class MidiConnectionSheet extends StatelessWidget {
  const MidiConnectionSheet({super.key, required this.midiService});

  final MidiService midiService;

  static Future<void> show(BuildContext context, MidiService midiService) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      builder: (context) => MidiConnectionSheet(midiService: midiService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: midiService,
      builder: (context, child) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.usb, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Conexión USB',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.labelBright,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sliderz envía MIDI por cable USB. Funciona con '
                    'cualquier DAW, app o dispositivo que reciba MIDI.',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 12),
                  _DeviceSection(midiService: midiService),
                  if (midiService.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      midiService.error!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const _SetupSteps(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeviceSection extends StatelessWidget {
  const _DeviceSection({required this.midiService});

  final MidiService midiService;

  @override
  Widget build(BuildContext context) {
    final outbound = midiService.outboundDevices;
    final selected = midiService.outputDevice;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: neumorphicDecoration(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Destino MIDI USB',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.labelBright,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: midiService.isConnecting
                    ? null
                    : () => midiService.refreshDevices(),
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Actualizar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  textStyle: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (outbound.isEmpty)
            Text(
              'No hay destinos USB visibles. Conecta un destino MIDI '
              'compatible y pulsa Actualizar.',
              style: Theme.of(context).textTheme.labelSmall,
            )
          else
            ...outbound.map((device) {
              final isSelected = selected?.id == device.id;
              final isConnected = device.connected;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.panelElevated,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: midiService.isConnecting
                        ? null
                        : () => midiService.selectOutputDevice(device),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _iconForType(device.type),
                            size: 16,
                            color: isConnected
                                ? AppColors.success
                                : AppColors.label,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.name,
                                  style: TextStyle(
                                    color: AppColors.labelBright,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _typeLabel(device.type),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected && isConnected)
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.success,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  IconData _iconForType(MidiDeviceType type) {
    switch (type) {
      case MidiDeviceType.serial:
        return Icons.usb;
      case MidiDeviceType.ble:
        return Icons.bluetooth;
      default:
        return Icons.device_hub;
    }
  }

  String _typeLabel(MidiDeviceType type) {
    switch (type) {
      case MidiDeviceType.serial:
        return 'USB';
      case MidiDeviceType.virtual:
        return 'Virtual';
      case MidiDeviceType.ownVirtual:
        return 'Virtual propio';
      case MidiDeviceType.ble:
        return 'Bluetooth';
      case MidiDeviceType.network:
        return 'Red';
      case MidiDeviceType.unknown:
        return 'Desconocido';
    }
  }
}

class _SetupSteps extends StatelessWidget {
  const _SetupSteps();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: neumorphicDecoration(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración USB',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.labelBright,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          const _Step(
            number: '1',
            text: 'Conecta este dispositivo a un destino MIDI USB compatible.',
          ),
          const _Step(
            number: '2',
            text:
                'En iPhone/Mac, activa IDAM si usas ese flujo. En Android, '
                'usa USB OTG o una interfaz USB MIDI compatible.',
          ),
          const _Step(
            number: '3',
            text:
                'Abre tu DAW o app MIDI y confirma que el destino aparece '
                'como entrada MIDI disponible.',
          ),
          const _Step(
            number: '4',
            text:
                'En Sliderz, elige ese destino arriba. En tu DAW o app MIDI, '
                'selecciona la entrada correspondiente y asigna los controles.',
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.panelElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}
