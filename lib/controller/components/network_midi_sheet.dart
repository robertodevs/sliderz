import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'package:sliderz/midi/services/midi_service.dart';
import 'package:sliderz/theme/app_theme.dart';

class NetworkMidiSheet extends StatelessWidget {
  const NetworkMidiSheet({super.key, required this.midiService});

  final MidiService midiService;

  static Future<void> show(
    BuildContext context,
    MidiService midiService,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      builder: (context) => NetworkMidiSheet(midiService: midiService),
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
                      const Icon(Icons.cable, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Conexión con MainStage',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.labelBright,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DeviceSection(midiService: midiService),
                  if (midiService.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      midiService.error!,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: const Color(0xFFEF4444)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (midiService.networkSupported)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'MIDI por red (Wi‑Fi)',
                        style: TextStyle(
                          color: AppColors.labelBright,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        midiService.networkEnabled
                            ? 'Activo — útil si no usas USB o como respaldo'
                            : 'Desactivado — USB puede seguir funcionando',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      value: midiService.networkEnabled,
                      activeThumbColor: AppColors.accent,
                      onChanged: (enabled) =>
                          midiService.setNetworkEnabled(enabled),
                    )
                  else
                    Text(
                      'MIDI por red no está disponible en esta plataforma. '
                      'Puedes usar USB.',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
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
                  'Destino MIDI',
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
              'No hay destinos MIDI con salida. Conecta USB o activa MIDI por red '
              'y pulsa Actualizar.',
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
                                  style:
                                      Theme.of(context).textTheme.labelSmall,
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
      case MidiDeviceType.network:
        return Icons.wifi;
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
      case MidiDeviceType.network:
        return 'Red (Wi‑Fi)';
      case MidiDeviceType.serial:
        return 'USB / nativo';
      case MidiDeviceType.ble:
        return 'Bluetooth';
      case MidiDeviceType.virtual:
        return 'Virtual';
      case MidiDeviceType.ownVirtual:
        return 'Virtual propio';
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
            'Opción A — USB (recomendado)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.labelBright,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: 8),
          const _Step(
            number: '1',
            text:
                'Conecta el iPhone al Mac por USB y pulsa Confiar en el iPhone.',
          ),
          const _Step(
            number: '2',
            text:
                'En Configuración de Audio y MIDI → Dispositivos de audio, selecciona el iPhone y pulsa Activar (IDAM).',
          ),
          const _Step(
            number: '3',
            text:
                'Abre Ventana → Mostrar estudio MIDI. Debe aparecer un dispositivo "iPhone". Los canales 1 y 2 de la ventana de audio no son MIDI.',
          ),
          const _Step(
            number: '4',
            text:
                'En MainStage, elige la entrada MIDI "iPhone" (o "Sliderz" en red) y usa Learn.',
          ),
          const SizedBox(height: 12),
          Text(
            'Opción B — Wi‑Fi (red)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.labelBright,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: 8),
          const _Step(
            number: '1',
            text:
                'Mac e iPhone en la misma red Wi‑Fi. Activa MIDI por red arriba.',
          ),
          const _Step(
            number: '2',
            text:
                'En el Mac: estudio MIDI → doble clic en Red → sesión en línea.',
          ),
          const _Step(
            number: '3',
            text:
                'Conecta el iPhone desde Directorio. En MainStage, elige esa entrada MIDI.',
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
