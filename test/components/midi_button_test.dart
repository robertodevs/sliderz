import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/common/components/midi_button.dart';
import 'package:sliderz/theme/app_theme.dart';

import '../helpers/test_app.dart';

void main() {
  group('MidiButton', () {
    testWidgets('renders label text', (tester) async {
      await pumpControlWidget(
        tester,
        MidiButton(
          label: 'S',
          momentary: false,
          onTap: () {},
        ),
      );

      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await pumpControlWidget(
        tester,
        MidiButton(
          icon: Icons.play_arrow,
          onPressed: () {},
          onReleased: () {},
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('toggle button calls onTap', (tester) async {
      var tapped = false;

      await pumpControlWidget(
        tester,
        MidiButton(
          label: 'M',
          momentary: false,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.text('M'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('toggle button shows active state', (tester) async {
      await pumpControlWidget(
        tester,
        MidiButton(
          label: 'R',
          momentary: false,
          active: true,
          accentColor: AppColors.channelColor(0),
          onTap: () {},
        ),
      );

      final button = tester.widget<MidiButton>(find.byType(MidiButton));
      expect(button.active, isTrue);
    });

    testWidgets('momentary button fires press on down and release on up',
        (tester) async {
      var pressed = false;
      var released = false;

      await pumpControlWidget(
        tester,
        MidiButton(
          icon: Icons.stop,
          size: AppTouch.transportButton,
          onPressed: () => pressed = true,
          onReleased: () => released = true,
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.stop)),
      );
      await tester.pump();

      expect(pressed, isTrue);
      expect(released, isFalse);

      await gesture.up();
      await tester.pump();

      expect(released, isTrue);
    });
  });
}
