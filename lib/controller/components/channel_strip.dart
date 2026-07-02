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
    required this.onSoloToggle,
    required this.onMuteToggle,
    required this.onRecordToggle,
  });

  final void Function(int index, double value) onFaderChanged;
  final void Function(int index, double value) onKnobChanged;
  final void Function(int index) onSoloToggle;
  final void Function(int index) onMuteToggle;
  final void Function(int index) onRecordToggle;
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      decoration: neumorphicDecoration(
        color: AppColors.panel,
        radius: 14,
        borderColor: _color.withValues(alpha: 0.2),
      ),
      child: Column(
        children: [
          MidiKnob(
            value: state.knobValue,
            size: AppTouch.knobSize,
            accentColor: _color,
            onChanged: (value) => handlers.onKnobChanged(index, value),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: AppTouch.minTarget,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MidiButton(
                        label: 'S',
                        momentary: false,
                        active: state.soloActive,
                        accentColor: _color,
                        onTap: () => handlers.onSoloToggle(index),
                      ),
                      const SizedBox(height: 4),
                      MidiButton(
                        label: 'M',
                        momentary: false,
                        active: state.muteActive,
                        accentColor: _color,
                        onTap: () => handlers.onMuteToggle(index),
                      ),
                      const SizedBox(height: 4),
                      MidiButton(
                        label: 'R',
                        momentary: false,
                        active: state.recordActive,
                        accentColor: _color,
                        onTap: () => handlers.onRecordToggle(index),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: AppTouch.faderLaneWidth,
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
          const SizedBox(height: 4),
          Text(
            '${index + 1}',
            style: TextStyle(
              color: _color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
