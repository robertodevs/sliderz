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
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _lighten(color, 0.06),
        _darken(color, 0.08),
      ],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: _uniformBorder(
      borderColor ?? AppColors.border.withValues(alpha: 0.6),
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x14FFFFFF),
        blurRadius: 2,
        offset: Offset(-1, -1),
      ),
    ],
  );
}

BoxDecoration controlButtonDecoration({
  double radius = 8,
  bool pressed = false,
  bool active = false,
  Color? accent,
  bool glowWhenActive = true,
}) {
  if (pressed) return _pressedButtonDecoration(radius, accent);
  if (active) {
    return _activeButtonDecoration(
      radius,
      accent ?? AppColors.accent,
      glowWhenActive,
    );
  }
  return _raisedButtonDecoration(radius);
}

BoxDecoration faderTrackDecoration({double radius = 3}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A0E14), Color(0xFF1A2433)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: _uniformBorder(Colors.black.withValues(alpha: 0.55)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.55),
        blurRadius: 3,
        offset: const Offset(-1, -1),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.05),
        blurRadius: 2,
        offset: const Offset(1, 1),
      ),
    ],
  );
}

BoxDecoration faderFillDecoration({
  required Color accent,
  double radius = 3,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        accent.withValues(alpha: 0.95),
        accent.withValues(alpha: 0.75),
      ],
    ),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.glow(accent, 0.65),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  );
}

BoxDecoration faderCapDecoration({
  required Color accent,
  bool pressed = false,
  double radius = 8,
}) {
  if (pressed) {
    return _pressedButtonDecoration(radius, accent);
  }
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E2836), Color(0xFF141C28)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: _uniformBorder(accent.withValues(alpha: 0.35)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 8,
        offset: Offset(3, 5),
      ),
      BoxShadow(
        color: Color(0x18FFFFFF),
        blurRadius: 4,
        offset: Offset(-1, -1),
      ),
    ],
  );
}

BoxDecoration faderCapGrooveDecoration({required Color accent}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withValues(alpha: 0.45),
        Colors.black.withValues(alpha: 0.25),
      ],
    ),
    borderRadius: BorderRadius.circular(2),
    border: _uniformBorder(Colors.black.withValues(alpha: 0.35)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  );
}

BoxDecoration _raisedButtonDecoration(double radius) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E2836), Color(0xFF141C28)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: _uniformBorder(AppColors.border.withValues(alpha: 0.75)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x55000000),
        blurRadius: 8,
        offset: Offset(3, 4),
      ),
      BoxShadow(
        color: Color(0x18FFFFFF),
        blurRadius: 4,
        offset: Offset(-1, -1),
      ),
    ],
  );
}

BoxDecoration _pressedButtonDecoration(double radius, Color? accent) {
  final tint = accent ?? AppColors.border;
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _darken(const Color(0xFF141C28), 0.04),
        Color.alphaBlend(tint.withValues(alpha: 0.12), const Color(0xFF1A2433)),
      ],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: _uniformBorder(
      Color.alphaBlend(tint.withValues(alpha: 0.2), AppColors.border),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.45),
        blurRadius: 4,
        offset: const Offset(-1, -1),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.04),
        blurRadius: 3,
        offset: const Offset(2, 2),
      ),
    ],
  );
}

BoxDecoration _activeButtonDecoration(
  double radius,
  Color accent,
  bool glow,
) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.alphaBlend(accent.withValues(alpha: 0.24), const Color(0xFF1E2836)),
        Color.alphaBlend(accent.withValues(alpha: 0.12), const Color(0xFF141C28)),
      ],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: _uniformBorder(accent.withValues(alpha: 0.45)),
    boxShadow: [
      if (glow)
        BoxShadow(
          color: AppColors.glow(accent, 0.35),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      const BoxShadow(
        color: Color(0x55000000),
        blurRadius: 8,
        offset: Offset(3, 4),
      ),
      const BoxShadow(
        color: Color(0x14FFFFFF),
        blurRadius: 3,
        offset: Offset(-1, -1),
      ),
    ],
  );
}

Border _uniformBorder(Color color) => Border.all(color: color, width: 1);

Color _lighten(Color color, double amount) {
  return Color.lerp(color, Colors.white, amount) ?? color;
}

Color _darken(Color color, double amount) {
  return Color.lerp(color, Colors.black, amount) ?? color;
}
