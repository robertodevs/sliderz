import 'package:sliderz/controller/blocs/controller_bloc.dart';
import 'package:sliderz/midi/services/midi_service.dart';

class Injector {
  Injector._();

  static final Injector instance = Injector._();

  MidiService? _midiService;
  ControllerBloc? _controllerBloc;

  MidiService get midiService {
    final service = _midiService;
    if (service == null) {
      throw StateError('Injector not initialized. Call init() first.');
    }
    return service;
  }

  ControllerBloc get controllerBloc {
    final bloc = _controllerBloc;
    if (bloc == null) {
      throw StateError('Injector not initialized. Call init() first.');
    }
    return bloc;
  }

  void init({MidiService? midiService}) {
    dispose();
    _midiService = midiService ?? MidiService();
    _controllerBloc = ControllerBloc(_midiService!);
  }

  void dispose() {
    _controllerBloc?.dispose();
    _midiService?.dispose();
    _controllerBloc = null;
    _midiService = null;
  }
}
