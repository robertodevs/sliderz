import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sliderz/controller/blocs/controller_bloc.dart';
import 'package:sliderz/controller/components/channel_strip.dart';
import 'package:sliderz/controller/components/status_bar.dart';
import 'package:sliderz/controller/components/transport_panel.dart';
import 'package:sliderz/core/injector.dart';
import 'package:sliderz/midi/services/midi_service.dart';
import 'package:sliderz/theme/app_theme.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  late final ControllerBloc _controllerBloc;
  late final MidiService _midiService;
  late final ChannelHandlers _channelHandlers;

  @override
  void initState() {
    super.initState();
    _controllerBloc = Injector.instance.controllerBloc;
    _midiService = Injector.instance.midiService;
    _channelHandlers = ChannelHandlers(
      onFaderChanged: _controllerBloc.setFader,
      onKnobChanged: _controllerBloc.setKnob,
      onSoloPressed: _controllerBloc.pressSolo,
      onSoloReleased: _controllerBloc.releaseSolo,
      onMutePressed: _controllerBloc.pressMute,
      onMuteReleased: _controllerBloc.releaseMute,
      onRecordPressed: _controllerBloc.pressRecord,
      onRecordReleased: _controllerBloc.releaseRecord,
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_controllerBloc, _midiService]),
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.backgroundGradientEnd,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  StatusBar(midiService: _midiService),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 720;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TransportPanel(
                                onTransport:
                                    _controllerBloc.sendTransportMomentary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: compact
                                    ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          width: 680,
                                          child: _buildChannelRow(),
                                        ),
                                      )
                                    : _buildChannelRow(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Row _buildChannelRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        _controllerBloc.channels.length,
        (index) => ChannelStrip(
          index: index,
          state: _controllerBloc.channels[index],
          handlers: _channelHandlers,
        ),
      ),
    );
  }
}
