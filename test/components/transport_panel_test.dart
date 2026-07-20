import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/controller/components/transport_panel.dart';
import 'package:sliderz/midi/models/nanokontrol2_mapping.dart';

import '../helpers/test_app.dart';

void main() {
  group('TransportPanel', () {
    testWidgets('shows navigation section labels', (tester) async {
      await pumpControlWidget(
        tester,
        SizedBox(height: 320, child: TransportPanel(onTransport: (_) {})),
      );

      expect(find.text('TRACK'), findsOneWidget);
      expect(find.text('MARKER'), findsOneWidget);
      expect(find.text('CYCLE'), findsOneWidget);
      expect(find.text('SET'), findsOneWidget);
    });

    testWidgets('marker set sends mapping cc on press', (tester) async {
      final sent = <int>[];

      await pumpControlWidget(
        tester,
        SizedBox(height: 320, child: TransportPanel(onTransport: sent.add)),
      );

      await tester.tap(find.text('SET'));
      await tester.pump();

      expect(sent, contains(NanoKontrol2Mapping.markerSet));
    });

    testWidgets('play transport button sends play cc on press down', (
      tester,
    ) async {
      final sent = <int>[];

      await pumpControlWidget(
        tester,
        SizedBox(height: 320, child: TransportPanel(onTransport: sent.add)),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.play_arrow)),
      );
      await tester.pump();

      expect(sent, contains(NanoKontrol2Mapping.play));

      await gesture.up();
      await tester.pump();
    });

    testWidgets('track navigation buttons send left and right cc', (
      tester,
    ) async {
      final sent = <int>[];

      await pumpControlWidget(
        tester,
        SizedBox(height: 320, child: TransportPanel(onTransport: sent.add)),
      );

      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pump();

      expect(sent, contains(NanoKontrol2Mapping.trackLeft));
      expect(sent, contains(NanoKontrol2Mapping.trackRight));
    });
  });
}
