import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/common/components/midi_knob.dart';
import 'package:sliderz/theme/app_theme.dart';

import '../helpers/test_app.dart';

void main() {
  group('MidiKnob', () {
    testWidgets('renders knob control', (tester) async {
      await pumpControlWidget(
        tester,
        MidiKnob(
          value: 0.5,
          accentColor: AppColors.channelColor(0),
          onChanged: (_) {},
        ),
      );

      expect(find.byType(MidiKnob), findsOneWidget);
    });

    testWidgets('dragging up increases value', (tester) async {
      final values = <double>[];

      await pumpControlWidget(
        tester,
        MidiKnob(
          value: 0.4,
          accentColor: AppColors.channelColor(3),
          onChanged: values.add,
        ),
      );

      await tester.drag(find.byType(MidiKnob), const Offset(0, -40));
      await tester.pump();

      expect(values, isNotEmpty);
      expect(values.last, greaterThan(0.4));
    });

    testWidgets('dragging down decreases value', (tester) async {
      final values = <double>[];

      await pumpControlWidget(
        tester,
        MidiKnob(
          value: 0.6,
          accentColor: AppColors.channelColor(4),
          onChanged: values.add,
        ),
      );

      await tester.drag(find.byType(MidiKnob), const Offset(0, 40));
      await tester.pump();

      expect(values, isNotEmpty);
      expect(values.last, lessThan(0.6));
    });
  });
}
