import 'package:flutter/material.dart' hide Image;
import '../engine/er_engine.dart';
import '../models/er_models.dart';

class ErPainter extends CustomPainter {
  final EndlessRunnerEngine engine;
  final int tick;

  const ErPainter({required this.engine, required this.tick});

  @override
  bool shouldRepaint(ErPainter old) => old.tick != tick;

  // ── Paints ────────────────────────────────────────────────────────────────────
  static final _fill = Paint()..style = PaintingStyle.fill;
  static final _stroke = Paint()..style = PaintingStyle.stroke;
  static final _pixelPaint = Paint()..filterQuality = FilterQuality.none;

  // ── Main ─────────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    if (!engine.initialized) {
      canvas.drawRect(
        Offset.zero & size,
        _fill..color = const Color(0xFF1A6EBF),
      );
      return;
    }

    _drawSky(canvas, size);
    _drawStars(canvas, size);
    _drawClouds(canvas);
    _drawGround(canvas, size);
    _drawObstacles(canvas);
    _drawPlayer(canvas);
  }

  // ── Sky ───────────────────────────────────────────────────────────────────────

  void _drawSky(Canvas canvas, Size size) {
    final (idx, blend) = engine.skyPhase;
    final next = (idx + 1) % 4;
    final a = kSkyPhases[idx];
    final b = kSkyPhases[next];

    final topColor = Color.lerp(a.top, b.top, blend)!;
    final bottomColor = Color.lerp(a.bottom, b.bottom, blend)!;

    // Two-tone sky: upper 60% top color, lower 40% bottom color
    final splitY = size.height * 0.5;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, splitY),
      _fill..color = topColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, splitY, size.width, engine.groundY - splitY),
      _fill..color = bottomColor,
    );
  }

  // ── Stars (visible at night/dusk) ─────────────────────────────────────────────

  void _drawStars(Canvas canvas, Size size) {
    // Night = phase 3 (skyTime 0.75-1.0), also dusk blend
    final (idx, blend) = engine.skyPhase;
    double visibility = 0;
    if (idx == 3) visibility = 0.4 + blend * 0.6; // night fading in
    if (idx == 2) visibility = blend * 0.4; // dusk → night
    if (visibility <= 0.01) return;

    for (final s in engine.stars) {
      _fill.color = Colors.white.withOpacity(s.opacity * visibility);
      canvas.drawRect(
        Rect.fromLTWH(s.x, s.y, s.size, s.size),
        _fill,
      );
    }
  }

  // ── Clouds ────────────────────────────────────────────────────────────────────

  void _drawClouds(Canvas canvas) {
    final (idx, blend) = engine.skyPhase;
    final next = (idx + 1) % 4;
    // Cloud color blends from sky bottom color to slightly brighter
    final skyBottom =
        Color.lerp(kSkyPhases[idx].bottom, kSkyPhases[next].bottom, blend)!;
    final cloudColor = Color.lerp(skyBottom, Colors.white, 0.55)!;

    for (final c in engine.clouds) {
      _fill.color = cloudColor;
      final w = 64 * c.scale;
      final h = 28 * c.scale;
      // Pixel-art cloud: 3 stacked rectangles
      canvas.drawRect(Rect.fromLTWH(c.x, c.y + h * 0.4, w, h * 0.6), _fill);
      canvas.drawRect(
          Rect.fromLTWH(c.x + w * 0.15, c.y + h * 0.2, w * 0.7, h * 0.5),
          _fill);
      canvas.drawRect(
          Rect.fromLTWH(c.x + w * 0.3, c.y, w * 0.4, h * 0.35), _fill);
    }
  }

  // ── Ground ────────────────────────────────────────────────────────────────────

  void _drawGround(Canvas canvas, Size size) {
    final (idx, blend) = engine.skyPhase;
    final next = (idx + 1) % 4;
    final grassColor = Color.lerp(
        kSkyPhases[idx].groundTop, kSkyPhases[next].groundTop, blend)!;
    final dirtColor = Color.lerp(
        kSkyPhases[idx].groundBody, kSkyPhases[next].groundBody, blend)!;

    final gy = engine.groundY;
    final gBot = size.height;

    for (final seg in engine.ground) {
      // Grass strip (top 8px)
      canvas.drawRect(
          Rect.fromLTWH(seg.x, gy, seg.width, 8), _fill..color = grassColor);
      // Dirt body
      canvas.drawRect(Rect.fromLTWH(seg.x, gy + 8, seg.width, gBot - gy - 8),
          _fill..color = dirtColor);

      // Pixel tile lines — vertical every 16px
      _stroke
        ..color = dirtColor.withOpacity(0.5)
        ..strokeWidth = 1;
      var tx = (seg.x / 16).ceil() * 16.0;
      while (tx < seg.x + seg.width) {
        canvas.drawLine(Offset(tx, gy + 8), Offset(tx, gBot), _stroke);
        tx += 16;
      }
      // Horizontal tile line at 24px below grass
      canvas.drawLine(
        Offset(seg.x, gy + 24),
        Offset(seg.x + seg.width, gy + 24),
        _stroke,
      );
    }

    // Pit void — dark below ground between segments
    _fill.color = const Color(0xFF000000).withOpacity(0.6);
    canvas.drawRect(Rect.fromLTWH(0, gy, size.width, gBot - gy), _fill);
    // Re-draw ground segments on top
    for (final seg in engine.ground) {
      canvas.drawRect(
        Rect.fromLTWH(seg.x, gy, seg.width, gBot - gy),
        _fill..color = dirtColor,
      );
      canvas.drawRect(
        Rect.fromLTWH(seg.x, gy, seg.width, 8),
        _fill..color = grassColor,
      );
    }
  }

  // ── Obstacles ─────────────────────────────────────────────────────────────────

  void _drawObstacles(Canvas canvas) {
    for (final obs in engine.obstacles) {
      switch (obs.type) {
        case ObstacleType.block:
          _drawBlock(canvas, obs);
        case ObstacleType.spike:
          _drawSpike(canvas, obs);
        case ObstacleType.aerialBar:
          _drawAerialBar(canvas, obs);
      }
    }
  }

  void _drawBlock(Canvas canvas, ErObstacle obs) {
    const base = Color(0xFF8B7355);
    const dark = Color(0xFF6B5535);
    const light = Color(0xFFAA9370);

    canvas.drawRect(obs.rect, _fill..color = base);
    // Top highlight
    canvas.drawRect(
      Rect.fromLTWH(obs.x, obs.y, obs.width, 4),
      _fill..color = light,
    );
    // Right shadow
    canvas.drawRect(
      Rect.fromLTWH(obs.x + obs.width - 4, obs.y, 4, obs.height),
      _fill..color = dark,
    );
    // Pixel tile grid
    _stroke
      ..color = dark
      ..strokeWidth = 1;
    canvas.drawRect(
      Rect.fromLTWH(obs.x + 2, obs.y + 2, obs.width - 4, obs.height - 4),
      _stroke,
    );
  }

  void _drawSpike(Canvas canvas, ErObstacle obs) {
    final path = Path()
      ..moveTo(obs.x + obs.width / 2, obs.y)
      ..lineTo(obs.x + obs.width, obs.y + obs.height)
      ..lineTo(obs.x, obs.y + obs.height)
      ..close();
    canvas.drawPath(path, _fill..color = const Color(0xFFD44020));

    // Inner lighter triangle
    const inset = 4.0;
    final inner = Path()
      ..moveTo(obs.x + obs.width / 2, obs.y + inset * 2)
      ..lineTo(obs.x + obs.width - inset, obs.y + obs.height - inset)
      ..lineTo(obs.x + inset, obs.y + obs.height - inset)
      ..close();
    canvas.drawPath(
        inner, _fill..color = const Color(0xFFFF6040).withOpacity(0.5));
  }

  void _drawAerialBar(Canvas canvas, ErObstacle obs) {
    // Main bar
    canvas.drawRect(obs.rect, _fill..color = const Color(0xFF2A2A4A));

    // Warning stripes (yellow/black diagonal pixel pattern)
    const stripeW = 12.0;
    _fill.color = const Color(0xFFFFCC00);
    var sx = obs.x;
    int i = 0;
    while (sx < obs.x + obs.width) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
              sx, obs.y, stripeW.clamp(0, obs.x + obs.width - sx), obs.height),
          _fill,
        );
      }
      sx += stripeW;
      i++;
    }

    // Border
    canvas.drawRect(
      obs.rect,
      _stroke
        ..color = const Color(0xFF4A4A6A)
        ..strokeWidth = 1.5,
    );

    // Chains hanging down from bar
    _stroke
      ..color = const Color(0xFF666688)
      ..strokeWidth = 1.5;
    for (final cx in [obs.x + 8, obs.x + obs.width - 8]) {
      canvas.drawLine(
          Offset(cx, obs.y + obs.height), Offset(cx, engine.groundY), _stroke);
    }
  }

  // ── Player ────────────────────────────────────────────────────────────────────

  void _drawPlayer(Canvas canvas) {
    final p = engine.player;
    if (p.isInvincible && (tick ~/ 3) % 2 == 0) return;

    final cx = ErPlayer.fixedX;
    final py = p.y;
    final pw = p.currentWidth;
    final ph = p.currentHeight;

    if (p.isSliding) {
      _drawPlayerSliding(canvas, cx, py, pw, ph);
    } else {
      _drawPlayerStanding(canvas, cx, py, pw, ph, p);
    }
  }

  void _drawPlayerStanding(
      Canvas canvas, double cx, double py, double pw, double ph, ErPlayer p) {
    const bodyColor = Color(0xFF3A7BD5);
    const headColor = Color(0xFFFFCC99);
    const legColorA = Color(0xFF2A5BAA);
    const legColorB = Color(0xFF1E4A8A);
    const shoeColor = Color(0xFF1A1A1A);

    // Legs (animated walk)
    final legW = pw * 0.38;
    final legH = ph * 0.28;
    final legY = py + ph - legH;
    // Left leg
    final leftOffset = p.legFrame == 0 ? -2.0 : 2.0;
    final rightOffset = p.legFrame == 0 ? 2.0 : -2.0;
    canvas.drawRect(
      Rect.fromLTWH(cx - pw * 0.25, legY + leftOffset, legW, legH),
      _fill..color = legColorA,
    );
    // Right leg
    canvas.drawRect(
      Rect.fromLTWH(cx + pw * 0.25 - legW, legY + rightOffset, legW, legH),
      _fill..color = legColorB,
    );
    // Shoes
    canvas.drawRect(
      Rect.fromLTWH(cx - pw * 0.28, legY + legH + leftOffset, legW + 2, 4),
      _fill..color = shoeColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          cx + pw * 0.22 - legW, legY + legH + rightOffset, legW + 2, 4),
      _fill..color = shoeColor,
    );

    // Body
    canvas.drawRect(
      Rect.fromLTWH(cx - pw / 2, py + ph * 0.38, pw, ph * 0.44),
      _fill..color = bodyColor,
    );
    // Body highlight
    canvas.drawRect(
      Rect.fromLTWH(cx - pw / 2, py + ph * 0.38, pw * 0.3, ph * 0.44),
      _fill..color = const Color(0xFF5A9BF0).withOpacity(0.5),
    );

    // Head
    final headW = pw * 0.75;
    final headH = ph * 0.3;
    final headX = cx - headW / 2;
    final headY = py + ph * 0.06;
    canvas.drawRect(
        Rect.fromLTWH(headX, headY, headW, headH), _fill..color = headColor);

    // Eyes
    _fill.color = const Color(0xFF1A1A1A);
    canvas.drawRect(
        Rect.fromLTWH(cx - headW * 0.1, headY + headH * 0.3, 3, 3), _fill);
    canvas.drawRect(
        Rect.fromLTWH(cx + headW * 0.15, headY + headH * 0.3, 3, 3), _fill);

    // Hair
    canvas.drawRect(
      Rect.fromLTWH(headX, headY, headW, headH * 0.35),
      _fill..color = const Color(0xFF5C3010),
    );
  }

  void _drawPlayerSliding(
      Canvas canvas, double cx, double py, double pw, double ph) {
    const bodyColor = Color(0xFF3A7BD5);
    const headColor = Color(0xFFFFCC99);

    // Flat body
    canvas.drawRect(
      Rect.fromLTWH(cx - pw / 2, py, pw, ph * 0.55),
      _fill..color = bodyColor,
    );
    // Head to the right (lying down look)
    canvas.drawRect(
      Rect.fromLTWH(cx + pw * 0.25, py, pw * 0.38, ph * 0.85),
      _fill..color = headColor,
    );
    // Eye
    _fill.color = const Color(0xFF1A1A1A);
    canvas.drawRect(
      Rect.fromLTWH(cx + pw * 0.38, py + ph * 0.2, 3, 3),
      _fill,
    );
  }
}
