import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/core/injector.dart';
import 'package:sliderz/main.dart';

void main() {
  setUp(() => Injector.instance.init());
  tearDown(() => Injector.instance.dispose());

  testWidgets('Sliderz app loads controller screen', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SliderzApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('S L I D E R Z'), findsOneWidget);
    expect(find.text('TRACK'), findsOneWidget);
  });
}
