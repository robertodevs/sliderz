import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/core/injector.dart';
import 'package:sliderz/main.dart';

import 'package:sliderz/midi/services/midi_service.dart';

import '../helpers/test_app.dart';

void main() {
  setUp(() => Injector.instance.init(midiService: MidiService.testing()));

  tearDown(() => Injector.instance.dispose());

  group('ControllerScreen', () {
    testWidgets('loads main controller layout', (tester) async {
      await pumpSliderzApp(tester);

      await tester.pumpWidget(const SliderzApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('S L I D E R Z'), findsOneWidget);
      expect(find.text('TRACK'), findsOneWidget);
      expect(find.text('MARKER'), findsOneWidget);
      expect(find.text('CYCLE'), findsOneWidget);
      expect(find.text('CH 1'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('renders eight channel strips numbered 1 through 8',
        (tester) async {
      await pumpSliderzApp(tester);

      await tester.pumpWidget(const SliderzApp());
      await tester.pumpAndSettle();

      for (var channel = 1; channel <= 8; channel++) {
        expect(find.text('$channel'), findsOneWidget);
      }
    });

    testWidgets('toggling solo on first channel updates bloc state',
        (tester) async {
      await pumpSliderzApp(tester);

      await tester.pumpWidget(const SliderzApp());
      await tester.pumpAndSettle();

      final bloc = Injector.instance.controllerBloc;
      expect(bloc.channels[0].soloActive, isFalse);

      await tester.tap(find.text('S').first);
      await tester.pump();

      expect(bloc.channels[0].soloActive, isTrue);
    });

    testWidgets('opening settings shows USB connection sheet', (tester) async {
      await pumpSliderzApp(tester);

      await tester.pumpWidget(const SliderzApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Conexión USB'), findsOneWidget);
      expect(find.text('Destino MIDI USB'), findsOneWidget);
    });
  });
}
