import 'package:flutter/material.dart';

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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wifi, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'MIDI por red (Wi‑Fi)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.labelBright,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!midiService.networkSupported)
                  Text(
                    'MIDI por red solo está disponible en iOS y macOS.',
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                else ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Enviar MIDI por Wi‑Fi',
                      style: TextStyle(color: AppColors.labelBright, fontSize: 14),
                    ),
                    subtitle: Text(
                      midiService.networkEnabled
                          ? 'Activo — tu Mac puede recibir los controles'
                          : 'Desactivado — solo MIDI local en este dispositivo',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    value: midiService.networkEnabled,
                    activeThumbColor: AppColors.accent,
                    onChanged: (enabled) =>
                        midiService.setNetworkEnabled(enabled),
                  ),
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
                  const _SetupSteps(),
                ],
              ],
            ),
          ),
        );
      },
    );
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
            'Configurar en tu Mac (MainStage)',
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
                'Mac e iPhone/iPad en la misma red Wi‑Fi. Activa MIDI por red aquí.',
          ),
          const _Step(
            number: '2',
            text:
                'Abre Configuración de Audio y MIDI → Ventana → Mostrar estudio MIDI.',
          ),
          const _Step(
            number: '3',
            text:
                'Doble clic en Red → activa la sesión y marca "Dispositivo está en línea".',
          ),
          const _Step(
            number: '4',
            text:
                'Conecta tu iPhone/iPad desde Directorio. En MainStage, elige esa entrada MIDI.',
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
