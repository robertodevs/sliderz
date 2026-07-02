import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sliderz/controller/screens/controller_screen.dart';
import 'package:sliderz/core/injector.dart';
import 'package:sliderz/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Injector.instance.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SliderzApp());
}

class SliderzApp extends StatelessWidget {
  const SliderzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliderz',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ControllerScreen(),
    );
  }
}
