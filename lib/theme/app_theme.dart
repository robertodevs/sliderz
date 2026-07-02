import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF080C12);
  static const backgroundGradientEnd = Color(0xFF0E1520);
  static const panel = Color(0xFF121A26);
  static const panelElevated = Color(0xFF1A2433);
  static const border = Color(0xFF2A3544);
  static const label = Color(0xFF8B9BB4);
  static const labelBright = Color(0xFFE8EDF5);
  static const accent = Color(0xFFA855F7);
  static const success = Color(0xFF4ADE80);
  static const knobFace = Color(0xFF141C28);

  static const channelColors = [
    Color(0xFFA855F7), // 1 purple
    Color(0xFF3B82F6), // 2 blue
    Color(0xFF06B6D4), // 3 cyan
    Color(0xFF22C55E), // 4 green
    Color(0xFFEAB308), // 5 yellow
    Color(0xFFF97316), // 6 orange
    Color(0xFFEC4899), // 7 pink
    Color(0xFF8B5CF6), // 8 violet
  ];

  static Color channelColor(int index) =>
      channelColors[index.clamp(0, channelColors.length - 1)];

  static Color glow(Color color, [double opacity = 0.55]) =>
      color.withValues(alpha: opacity);
}

/// Minimum touch targets and fixed control dimensions (Apple HIG: 44pt).
class AppTouch {
  static const double minTarget = 44;
  static const double channelButton = 40;
  static const double transportButton = 44;
  static const double knobSize = 46;
  static const double faderCapWidth = 44;
  static const double faderCapHeight = 34;
  static const double faderTrackWidth = 5;
  static const double faderScaleWidth = 18;
  static const double faderLaneWidth =
      faderScaleWidth + 8 + faderCapWidth;
  static const double channelStripMinWidth =
      minTarget + faderLaneWidth + 16;
  static const double transportPanelWidth = 164;
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.panel,
      primary: AppColors.accent,
    ),
    textTheme: const TextTheme(
      labelSmall: TextStyle(
        color: AppColors.label,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
      ),
    ),
  );
}

BoxDecoration neumorphicDecoration({
  Color color = AppColors.panelElevated,
  double radius = 10,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor ?? AppColors.border.withValues(alpha: 0.6)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x14FFFFFF),
        blurRadius: 2,
        offset: Offset(0, -1),
      ),
    ],
  );
}
