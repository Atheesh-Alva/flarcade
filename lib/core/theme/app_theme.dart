import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Palette ──────────────────────────────────────────────────
  static const Color bg       = Color(0xFFF7F4EF); // warm cream
  static const Color surface  = Color(0xFFFFFFFF); // card white
  static const Color ink      = Color(0xFF1C1917); // near-black
  static const Color inkMuted = Color(0xFF9C9189); // warm grey
  static const Color inkFaint = Color(0xFFE2DDD8); // dividers
  static const Color accent   = Color(0xFFD4622A); // terracotta

  // ── Text Styles ───────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: ink,
    letterSpacing: -0.8,
    height: 1.1,
  );

  static const TextStyle labelCaps = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: inkMuted,
    letterSpacing: 1.4,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.2,
  );

  static const TextStyle cardBody = TextStyle(
    fontSize: 12,
    color: inkMuted,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static const TextStyle tagLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  // ── ThemeData ─────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.light(
          primary: accent,
          surface: surface,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        fontFamily: 'SF Pro Display', // falls back to system sans
      );
}
