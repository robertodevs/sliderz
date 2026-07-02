import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiService extends ChangeNotifier {
  MidiService() {
    unawaited(_initialize());
  }

  final MidiCommand _midi = MidiCommand();
  final List<MidiDevice> _devices = [];
  MidiDevice? _outputDevice;
  bool _ready = false;
  bool _connecting = false;
  String? _error;
  int _channel = 0;
  bool _networkSupported = false;
  bool _networkEnabled = false;
  StreamSubscription<MidiSetupChange>? _setupSubscription;

  bool get isReady => _ready;
  bool get isConnecting => _connecting;
  String? get error => _error;
  int get channel => _channel;
  bool get networkSupported => _networkSupported;
  bool get networkEnabled => _networkEnabled;
  MidiDevice? get outputDevice => _outputDevice;
  bool get isOutputConnected => _outputDevice?.connected ?? false;

  List<MidiDevice> get devices => List.unmodifiable(_devices);

  List<MidiDevice> get outboundDevices =>
      _devices.where(_canSendTo).toList(growable: false);

  String get connectionStatusLabel {
    if (_connecting) return 'Conectando MIDI...';
    if (isOutputConnected) {
      return 'MIDI → ${_outputDevice!.name}';
    }
    if (outboundDevices.isEmpty) {
      return 'MIDI sin destinos';
    }
    return 'MIDI sin conexión';
  }

  Future<void> _initialize() async {
    try {
      _midi.configureBleTransport(null);
      await _probeNetworkSupport();

      if (_networkSupported && !_networkEnabled) {
        await setNetworkEnabled(true);
      } else {
        _applyTransportPolicy();
      }

      _setupSubscription = _midi.onMidiSetupChanged?.listen((_) {
        unawaited(_onSetupChanged());
      });

      await _refreshDevices();
      await _autoConnectOutputDevice();
      _ready = true;
      _error = null;
    } catch (e) {
      _ready = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> _onSetupChanged() async {
    await _refreshDevices();
    await _autoConnectOutputDevice();
    notifyListeners();
  }

  Future<void> refreshDevices() async {
    await _refreshDevices();
    await _autoConnectOutputDevice();
    notifyListeners();
  }

  Future<void> _refreshDevices() async {
    final devices = await _midi.devices ?? const <MidiDevice>[];
    _devices
      ..clear()
      ..addAll(devices);
    if (kDebugMode) {
      _logDiscoveredDevices();
    }
  }

  void _logDiscoveredDevices() {
    if (_devices.isEmpty) {
      debugPrint('MIDI devices: (none)');
      return;
    }
    for (final device in _devices) {
      final outputs = device.outputPorts.length;
      final inputs = device.inputPorts.length;
      debugPrint(
        'MIDI device: "${device.name}" '
        'type=${device.type.name} '
        'connected=${device.connected} '
        'in=$inputs out=$outputs',
      );
    }
  }

  bool _canSendTo(MidiDevice device) {
    if (device.type == MidiDeviceType.ownVirtual) return false;
    return device.outputPorts.isNotEmpty;
  }

  MidiDevice _pickPreferredDevice(List<MidiDevice> candidates) {
    if (_networkEnabled) {
      final networkDevices = candidates
          .where((device) => device.type == MidiDeviceType.network)
          .toList();
      if (networkDevices.isNotEmpty) return networkDevices.first;
    }

    final usbDevices = candidates
        .where((device) => device.type == MidiDeviceType.serial)
        .toList();
    if (usbDevices.isNotEmpty) return usbDevices.first;

    return candidates.first;
  }

  Future<void> _autoConnectOutputDevice() async {
    final candidates = outboundDevices;
    if (candidates.isEmpty) {
      _outputDevice = null;
      return;
    }

    final current = _outputDevice;
    if (current != null && candidates.any((device) => device.id == current.id)) {
      final refreshed = candidates.firstWhere((device) => device.id == current.id);
      _outputDevice = refreshed;
      if (!refreshed.connected) {
        await _connectDevice(refreshed);
      }
      return;
    }

    await selectOutputDevice(_pickPreferredDevice(candidates));
  }

  Future<void> selectOutputDevice(MidiDevice device) async {
    if (!outboundDevices.any((candidate) => candidate.id == device.id)) {
      _error = 'El dispositivo "${device.name}" no admite envío MIDI.';
      notifyListeners();
      return;
    }

    final previous = _outputDevice;
    if (previous != null &&
        previous.id != device.id &&
        previous.connected) {
      _midi.disconnectDevice(previous);
    }

    _outputDevice = device;
    await _connectDevice(device);
  }

  Future<void> _connectDevice(MidiDevice device) async {
    if (device.connected) return;

    _connecting = true;
    _error = null;
    notifyListeners();

    try {
      await _midi.connectToDevice(device);
      if (kDebugMode) {
        debugPrint(
          'MIDI connected to "${device.name}" (${device.type.name})',
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('MIDI connect failed for "${device.name}": $e');
      }
    } finally {
      _connecting = false;
      notifyListeners();
    }
  }

  Future<void> _probeNetworkSupport() async {
    _midi.configureTransportPolicy(
      const MidiTransportPolicy(excludedTransports: {MidiTransport.ble}),
    );
    try {
      final enabled = await _midi.isNetworkSessionEnabled;
      _networkSupported = true;
      _networkEnabled = enabled ?? false;
    } on StateError {
      _networkSupported = false;
      _networkEnabled = false;
    }
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

    await _refreshDevices();
    await _autoConnectOutputDevice();
    notifyListeners();
  }

  void _applyTransportPolicy() {
    final excludedTransports = <MidiTransport>{MidiTransport.ble};
    if (!_networkEnabled) {
      excludedTransports.add(MidiTransport.network);
    }
    _midi.configureTransportPolicy(
      MidiTransportPolicy(excludedTransports: excludedTransports),
    );
  }

  void sendCc(int cc, int value) {
    if (!_ready) return;

    final target = _outputDevice;
    if (target == null || !target.connected) {
      if (kDebugMode) {
        debugPrint(
          'MIDI warning: no connected output device — CC not sent',
        );
      }
      return;
    }

    final clamped = value.clamp(0, 127);
    if (kDebugMode) {
      debugPrint(
        'MIDI → "${target.name}" CC ch=${_channel + 1} cc=$cc value=$clamped '
        '[0x${(0xB0 + _channel).toRadixString(16).toUpperCase()} '
        '${cc.toRadixString(16).padLeft(2, '0').toUpperCase()} '
        '${clamped.toRadixString(16).padLeft(2, '0').toUpperCase()}]',
      );
    }
    final data = Uint8List.fromList([0xB0 + _channel, cc, clamped]);
    _midi.sendData(data, deviceId: target.id);
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
    _midi.dispose();
    super.dispose();
  }
}
