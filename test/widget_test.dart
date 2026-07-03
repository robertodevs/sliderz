import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/core/injector.dart';
import 'package:sliderz/main.dart';

import 'package:sliderz/midi/services/midi_service.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('app smoke test loads controller screen', (tester) async {
    Injector.instance.init(midiService: MidiService.testing());
    addTearDown(Injector.instance.dispose);

    await pumpSliderzApp(tester);
    await tester.pumpWidget(const SliderzApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('S L I D E R Z'), findsOneWidget);
  });
}
