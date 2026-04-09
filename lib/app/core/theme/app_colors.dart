import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF6B1A);
  static const Color primaryDeep = Color(0xFFD94E0D);
  static const Color primarySoft = Color(0xFFFFA163);
  static const Color primaryMuted = Color(0xFF7D3514);

  static const Color background = Color(0xFF0C0A09);
  static const Color backgroundRaised = Color(0xFF16110F);
  static const Color surface = Color(0xFF1B1512);
  static const Color surfaceAlt = Color(0xFF241B17);
  static const Color inputFill = Color(0xFF211915);
  static const Color border = Color(0x1FFFFFFF);
  static const Color softBorder = Color(0x14FFFFFF);

  static const Color textPrimary = Color(0xFFF7EFE9);
  static const Color textMuted = Color(0xFFB8A79B);
  static const Color success = Color(0xFF3DD598);
  static const Color warning = Color(0xFFFFB347);
  static const Color danger = Color(0xFFFF6B6B);

  static const Color heroStart = Color(0xFF2A140B);
  static const Color heroMiddle = Color(0xFF4C200A);
  static const Color heroEnd = Color(0xFF120D0A);

  static const List<BoxShadow> primaryGlow = <BoxShadow>[
    BoxShadow(
      color: Color(0x33FF6B1A),
      blurRadius: 28,
      spreadRadius: 1,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> softShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 20,
      offset: Offset(0, 12),
    ),
  ];
}
