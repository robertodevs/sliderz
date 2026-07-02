import 'package:sliderz/controller/blocs/controller_bloc.dart';
import 'package:sliderz/midi/services/midi_service.dart';

class Injector {
  Injector._();

  static final Injector instance = Injector._();

  late final MidiService midiService;
  late final ControllerBloc controllerBloc;

  void init() {
    midiService = MidiService();
    controllerBloc = ControllerBloc(midiService);
  }

  void dispose() {
    controllerBloc.dispose();
    midiService.dispose();
  }
}
