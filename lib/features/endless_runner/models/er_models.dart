import 'dart:ui';

// ── Sky / day-night cycle ─────────────────────────────────────────────────────

class SkyPalette {
  final Color top;
  final Color bottom;
  final Color groundTop;   // grass
  final Color groundBody;  // dirt/stone

  const SkyPalette({
    required this.top,
    required this.bottom,
    required this.groundTop,
    required this.groundBody,
  });
}

const kSkyDawn = SkyPalette(
  top:        Color(0xFFB34A1E),
  bottom:     Color(0xFFFFBF80),
  groundTop:  Color(0xFF5D8A3C),
  groundBody: Color(0xFF7A5230),
);

const kSkyDay = SkyPalette(
  top:        Color(0xFF1A6EBF),
  bottom:     Color(0xFF74C0F5),
  groundTop:  Color(0xFF4A9C28),
  groundBody: Color(0xFF8B6620),
);

const kSkyDusk = SkyPalette(
  top:        Color(0xFF3A1060),
  bottom:     Color(0xFFD45000),
  groundTop:  Color(0xFF3D7020),
  groundBody: Color(0xFF6B4A18),
);

const kSkyNight = SkyPalette(
  top:        Color(0xFF04040F),
  bottom:     Color(0xFF0C1840),
  groundTop:  Color(0xFF2A5014),
  groundBody: Color(0xFF3A2808),
);

const kSkyPhases = [kSkyDawn, kSkyDay, kSkyDusk, kSkyNight];

// ── Ground segment ────────────────────────────────────────────────────────────

class GroundSegment {
  double x;
  final double width;

  GroundSegment({required this.x, required this.width});
}

// ── Obstacle ──────────────────────────────────────────────────────────────────

enum ObstacleType { block, spike, aerialBar }

class ErObstacle {
  double x;
  final double y, width, height;
  final ObstacleType type;

  ErObstacle._({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
  });

  factory ErObstacle.block({required double x, required double groundY}) =>
      ErObstacle._(
        x: x, y: groundY - 32, width: 28, height: 32, type: ObstacleType.block,
      );

  factory ErObstacle.spike({required double x, required double groundY}) =>
      ErObstacle._(
        x: x, y: groundY - 22, width: 20, height: 22, type: ObstacleType.spike,
      );

  factory ErObstacle.aerialBar({required double x, required double groundY}) =>
      ErObstacle._(
        x: x, y: groundY - 68, width: 64, height: 10, type: ObstacleType.aerialBar,
      );

  Rect get rect => Rect.fromLTWH(x, y, width, height);
}

// ── Cloud ─────────────────────────────────────────────────────────────────────

class ErCloud {
  double x;
  final double y, speed, scale;

  ErCloud({required this.x, required this.y, required this.speed, required this.scale});
}

// ── Star (night sky) ──────────────────────────────────────────────────────────

class ErStar {
  final double x, y, size, opacity;
  const ErStar({required this.x, required this.y, required this.size, required this.opacity});
}

// ── Player ────────────────────────────────────────────────────────────────────

class ErPlayer {
  static const double fixedX      = 90;
  static const double standWidth  = 18;
  static const double standHeight = 28;
  static const double slideWidth  = 26;
  static const double slideHeight = 14;
  static const double gravity     = 1300;
  static const double jumpVy      = -530;
  static const double slideDuration = 0.75;
  static const double invincibleDuration = 1.2;

  double y;
  double vy             = 0;
  bool onGround         = false;
  bool hasDoubleJump    = true;
  bool isSliding        = false;
  double slideTimer     = 0;
  bool isInvincible     = false;
  double invincibleTimer = 0;
  int legFrame          = 0; // 0 or 1 for walk animation
  double legTimer       = 0;

  ErPlayer({required this.y});

  double get currentWidth  => isSliding ? slideWidth  : standWidth;
  double get currentHeight => isSliding ? slideHeight : standHeight;

  double get left   => fixedX - currentWidth / 2;
  double get right  => fixedX + currentWidth / 2;
  double get bottom => y + currentHeight;

  Rect get rect => Rect.fromLTWH(left, y, currentWidth, currentHeight);
}
