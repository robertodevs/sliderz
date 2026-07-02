import 'package:flutter/material.dart';

import 'package:sliderz/common/components/midi_button.dart';
import 'package:sliderz/common/components/midi_fader.dart';
import 'package:sliderz/common/components/midi_knob.dart';
import 'package:sliderz/controller/models/channel_state.dart';
import 'package:sliderz/theme/app_theme.dart';

class ChannelHandlers {
  const ChannelHandlers({
    required this.onFaderChanged,
    required this.onKnobChanged,
    required this.onSoloPressed,
    required this.onSoloReleased,
    required this.onMutePressed,
    required this.onMuteReleased,
    required this.onRecordPressed,
    required this.onRecordReleased,
  });

  final void Function(int index, double value) onFaderChanged;
  final void Function(int index, double value) onKnobChanged;
  final void Function(int index) onSoloPressed;
  final void Function(int index) onSoloReleased;
  final void Function(int index) onMutePressed;
  final void Function(int index) onMuteReleased;
  final void Function(int index) onRecordPressed;
  final void Function(int index) onRecordReleased;
}

class ChannelStrip extends StatelessWidget {
  const ChannelStrip({
    super.key,
    required this.index,
    required this.state,
    required this.handlers,
  });

  final int index;
  final ChannelState state;
  final ChannelHandlers handlers;

  Color get _color => AppColors.channelColor(index);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
        decoration: neumorphicDecoration(
          color: AppColors.panel,
          radius: 14,
          borderColor: _color.withValues(alpha: 0.2),
        ),
        child: Column(
          children: [
            MidiKnob(
              value: state.knobValue,
              accentColor: _color,
              onChanged: (value) => handlers.onKnobChanged(index, value),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MidiButton(
                        label: 'S',
                        active: state.soloActive,
                        accentColor: _color,
                        size: 24,
                        onPressed: () => handlers.onSoloPressed(index),
                        onReleased: () => handlers.onSoloReleased(index),
                      ),
                      const SizedBox(height: 6),
                      MidiButton(
                        label: 'M',
                        active: state.muteActive,
                        accentColor: _color,
                        size: 24,
                        onPressed: () => handlers.onMutePressed(index),
                        onReleased: () => handlers.onMuteReleased(index),
                      ),
                      const SizedBox(height: 6),
                      MidiButton(
                        label: 'R',
                        active: state.recordActive,
                        accentColor: _color,
                        size: 24,
                        onPressed: () => handlers.onRecordPressed(index),
                        onReleased: () => handlers.onRecordReleased(index),
                      ),
                    ],
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: MidiFader(
                      value: state.faderValue,
                      accentColor: _color,
                      onChanged: (value) =>
                          handlers.onFaderChanged(index, value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${index + 1}',
              style: TextStyle(
                color: _color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
