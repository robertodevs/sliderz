import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiService extends ChangeNotifier {
  MidiService() {
    _init();
  }

  final MidiCommand _midi = MidiCommand();
  bool _ready = false;
  String? _error;
  int _channel = 0;
  bool _networkSupported = false;
  bool _networkEnabled = false;
  StreamSubscription<MidiSetupChange>? _setupSubscription;

  bool get isReady => _ready;
  String? get error => _error;
  int get channel => _channel;
  bool get networkSupported => _networkSupported;
  bool get networkEnabled => _networkEnabled;

  Future<void> _init() async {
    try {
      _midi.addVirtualDevice(name: 'Sliderz');
      await _loadNetworkState();
      _setupSubscription = _midi.onMidiSetupChanged?.listen((_) {
        notifyListeners();
      });
      _ready = true;
      _error = null;
    } catch (e) {
      _ready = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> _loadNetworkState() async {
    try {
      final enabled = await _midi.isNetworkSessionEnabled;
      _networkSupported = true;
      _networkEnabled = enabled ?? false;
    } on StateError {
      _networkSupported = false;
      _networkEnabled = false;
    }
    _applyTransportPolicy();
  }

  void setChannel(int channel) {
    _channel = channel.clamp(0, 15);
    notifyListeners();
  }

  Future<void> setNetworkEnabled(bool enabled) async {
    if (!_networkSupported || _networkEnabled == enabled) return;

    _error = null;

    if (!enabled) {
      _midi.setNetworkSessionEnabled(false);
    }

    _networkEnabled = enabled;
    _applyTransportPolicy();

    if (enabled) {
      try {
        _midi.setNetworkSessionEnabled(true);
      } catch (e) {
        _networkEnabled = false;
        _error = e.toString();
        _applyTransportPolicy();
      }
    }

    notifyListeners();
  }

  void _applyTransportPolicy() {
    final excludedTransports = <MidiTransport>{};
    if (!_networkEnabled) {
      excludedTransports.add(MidiTransport.network);
    }
    _midi.configureTransportPolicy(
      MidiTransportPolicy(excludedTransports: excludedTransports),
    );
  }

  void sendCc(int cc, int value) {
    if (!_ready) return;
    final clamped = value.clamp(0, 127);
    if (kDebugMode) {
      debugPrint(
        'MIDI → CC ch=${_channel + 1} cc=$cc value=$clamped '
        '[0x${(0xB0 + _channel).toRadixString(16).toUpperCase()} '
        '${cc.toRadixString(16).padLeft(2, '0').toUpperCase()} '
        '${clamped.toRadixString(16).padLeft(2, '0').toUpperCase()}]',
      );
    }
    final data = Uint8List.fromList([0xB0 + _channel, cc, clamped]);
    _midi.sendData(data);
  }

  void sendCcPress(int cc) => sendCc(cc, 127);

  void sendCcRelease(int cc) => sendCc(cc, 0);

  @override
  void dispose() {
    _setupSubscription?.cancel();
    if (_networkEnabled) {
      try {
        _midi.setNetworkSessionEnabled(false);
      } catch (_) {}
    }
    try {
      _midi.removeVirtualDevice(name: 'Sliderz');
    } catch (_) {}
    super.dispose();
  }
}
