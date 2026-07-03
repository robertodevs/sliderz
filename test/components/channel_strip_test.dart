import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/controller/components/channel_strip.dart';
import 'package:sliderz/controller/models/channel_state.dart';
import 'package:sliderz/theme/app_theme.dart';

import '../helpers/test_app.dart';

ChannelHandlers _noopHandlers() {
  return ChannelHandlers(
    onFaderChanged: (_, _) {},
    onKnobChanged: (_, _) {},
    onSoloToggle: (_) {},
    onMuteToggle: (_) {},
    onRecordToggle: (_) {},
  );
}

void main() {
  group('ChannelStrip', () {
    testWidgets('shows channel number and S M R buttons', (tester) async {
      await pumpControlWidget(
        tester,
        SizedBox(
          width: AppTouch.channelStripMinWidth,
          height: 320,
          child: ChannelStrip(
            index: 0,
            state: const ChannelState(),
            handlers: _noopHandlers(),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
    });

    testWidgets('solo toggle invokes handler for channel index', (tester) async {
      int? toggledIndex;

      await pumpControlWidget(
        tester,
        SizedBox(
          width: AppTouch.channelStripMinWidth,
          height: 320,
          child: ChannelStrip(
            index: 2,
            state: const ChannelState(),
            handlers: ChannelHandlers(
              onFaderChanged: (_, _) {},
              onKnobChanged: (_, _) {},
              onSoloToggle: (index) => toggledIndex = index,
              onMuteToggle: (_) {},
              onRecordToggle: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('S'));
      await tester.pump();

      expect(toggledIndex, 2);
    });

    testWidgets('mute and record toggles invoke handlers', (tester) async {
      int? muteIndex;
      int? recordIndex;

      await pumpControlWidget(
        tester,
        SizedBox(
          width: AppTouch.channelStripMinWidth,
          height: 320,
          child: ChannelStrip(
            index: 4,
            state: const ChannelState(),
            handlers: ChannelHandlers(
              onFaderChanged: (_, _) {},
              onKnobChanged: (_, _) {},
              onSoloToggle: (_) {},
              onMuteToggle: (index) => muteIndex = index,
              onRecordToggle: (index) => recordIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('M'));
      await tester.pump();
      await tester.tap(find.text('R'));
      await tester.pump();

      expect(muteIndex, 4);
      expect(recordIndex, 4);
    });
  });
}
