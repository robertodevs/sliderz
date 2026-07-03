import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sliderz/theme/app_theme.dart';

const Size kLandscapePhoneSize = Size(844, 390);

Future<void> pumpControlWidget(
  WidgetTester tester,
  Widget child, {
  Size surfaceSize = kLandscapePhoneSize,
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

Future<void> pumpSliderzApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(kLandscapePhoneSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}
