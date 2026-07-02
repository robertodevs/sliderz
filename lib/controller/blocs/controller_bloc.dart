import 'package:flutter/foundation.dart';

import 'package:sliderz/controller/models/channel_state.dart';
import 'package:sliderz/midi/models/nanokontrol2_mapping.dart';
import 'package:sliderz/midi/services/midi_service.dart';

class ControllerBloc extends ChangeNotifier {
  ControllerBloc(this._midiService)
      : _channels = List.generate(8, (_) => const ChannelState());

  final MidiService _midiService;
  final List<ChannelState> _channels;

  List<ChannelState> get channels => List.unmodifiable(_channels);

  void setFader(int index, double value) {
    _updateChannel(index, _channels[index].copyWith(faderValue: value));
    _midiService.sendCc(
      NanoKontrol2Mapping.faders[index],
      (value * 127).round(),
    );
  }

  void setKnob(int index, double value) {
    _updateChannel(index, _channels[index].copyWith(knobValue: value));
    _midiService.sendCc(
      NanoKontrol2Mapping.knobs[index],
      (value * 127).round(),
    );
  }

  void pressSolo(int index) {
    _updateChannel(index, _channels[index].copyWith(soloActive: true));
    _midiService.sendCcPress(NanoKontrol2Mapping.solo[index]);
  }

  void releaseSolo(int index) {
    _updateChannel(index, _channels[index].copyWith(soloActive: false));
    _midiService.sendCcRelease(NanoKontrol2Mapping.solo[index]);
  }

  void pressMute(int index) {
    _updateChannel(index, _channels[index].copyWith(muteActive: true));
    _midiService.sendCcPress(NanoKontrol2Mapping.mute[index]);
  }

  void releaseMute(int index) {
    _updateChannel(index, _channels[index].copyWith(muteActive: false));
    _midiService.sendCcRelease(NanoKontrol2Mapping.mute[index]);
  }

  void pressRecord(int index) {
    _updateChannel(index, _channels[index].copyWith(recordActive: true));
    _midiService.sendCcPress(NanoKontrol2Mapping.record[index]);
  }

  void releaseRecord(int index) {
    _updateChannel(index, _channels[index].copyWith(recordActive: false));
    _midiService.sendCcRelease(NanoKontrol2Mapping.record[index]);
  }

  void sendTransportMomentary(int cc) {
    _midiService.sendCcPress(cc);
    Future.delayed(const Duration(milliseconds: 80), () {
      _midiService.sendCcRelease(cc);
    });
  }

  void _updateChannel(int index, ChannelState state) {
    _channels[index] = state;
    notifyListeners();
  }
}
