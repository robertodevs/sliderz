import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/common/components/midi_fader.dart';
import 'package:sliderz/theme/app_theme.dart';

import '../helpers/test_app.dart';

void main() {
  group('MidiFader', () {
    testWidgets('renders scale labels', (tester) async {
      await pumpControlWidget(
        tester,
        SizedBox(
          width: MidiFader.laneWidth,
          height: 180,
          child: MidiFader(
            value: 0.5,
            accentColor: AppColors.channelColor(0),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('dragging updates value through onChanged', (tester) async {
      final values = <double>[];

      await pumpControlWidget(
        tester,
        SizedBox(
          width: MidiFader.laneWidth,
          height: 180,
          child: MidiFader(
            value: 0.5,
            accentColor: AppColors.channelColor(1),
            onChanged: values.add,
          ),
        ),
      );

      await tester.drag(find.byType(MidiFader), const Offset(0, -50));
      await tester.pump();

      expect(values, isNotEmpty);
      expect(values.last, greaterThan(0.5));
    });

    testWidgets('tap near top sets a higher value', (tester) async {
      final values = <double>[];

      await pumpControlWidget(
        tester,
        SizedBox(
          width: MidiFader.laneWidth,
          height: 180,
          child: MidiFader(
            value: 0.2,
            accentColor: AppColors.channelColor(2),
            onChanged: values.add,
          ),
        ),
      );

      await tester.tapAt(tester.getTopLeft(find.byType(MidiFader)) + const Offset(30, 20));
      await tester.pump();

      expect(values, isNotEmpty);
      expect(values.last, greaterThan(0.2));
    });
  });
}
