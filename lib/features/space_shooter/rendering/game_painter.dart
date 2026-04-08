import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/ss_engine.dart';
import '../models/ss_models.dart';

class GamePainter extends CustomPainter {
  final SpaceShooterEngine engine;
  final int tick;

  const GamePainter({required this.engine, required this.tick});

  @override
  bool shouldRepaint(GamePainter old) => old.tick != tick;

  // ── Paints (defined once, reused) ─────────────────────────────────────────────
  static final _bgPaint = Paint()..color = const Color(0xFF060912);
  static final _starPaint = Paint()..color = Colors.white;

  static final _playerPaint = Paint()
    ..color = const Color(0xFFD4622A)
    ..style = PaintingStyle.fill;

  static final _playerBulletPaint = Paint()
    ..color = const Color(0xFF00E5FF)
    ..style = PaintingStyle.fill;

  static final _enemyBulletPaint = Paint()
    ..color = const Color(0xFFFF4444)
    ..style = PaintingStyle.fill;

  static final _waveEnemyPaint = Paint()
    ..color = const Color(0xFF4CAF82)
    ..style = PaintingStyle.fill;

  static final _randomEnemyPaint = Paint()
    ..color = const Color(0xFFE8A838)
    ..style = PaintingStyle.fill;

  static final _bossPaint = Paint()
    ..color = const Color(0xFFE05C5C)
    ..style = PaintingStyle.fill;

  static final _bossDetailPaint = Paint()
    ..color = const Color(0xFFFF8080)
    ..style = PaintingStyle.fill;

  static final _healthBgPaint = Paint()
    ..color = const Color(0xFF1A1A2E)
    ..style = PaintingStyle.fill;

  static final _healthFillPaint = Paint()
    ..color = const Color(0xFFE05C5C)
    ..style = PaintingStyle.fill;

  // ── Main draw ─────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Offset.zero & size, _bgPaint);

    if (!engine.initialized) return;

    _drawStars(canvas);
    _drawBullets(canvas);
    _drawEnemies(canvas, size);
    _drawPlayer(canvas, tick);
    _drawExplosions(canvas);
  }

  // ── Stars ─────────────────────────────────────────────────────────────────────

  void _drawStars(Canvas canvas) {
    for (final s in engine.stars) {
      _starPaint.color = Colors.white.withOpacity(s.opacity);
      canvas.drawCircle(Offset(s.x, s.y), s.radius, _starPaint);
    }
  }

  // ── Bullets ───────────────────────────────────────────────────────────────────

  void _drawBullets(Canvas canvas) {
    for (final b in engine.bullets) {
      if (!b.isAlive) continue;
      final paint = b.isEnemy ? _enemyBulletPaint : _playerBulletPaint;
      canvas.drawRRect(
        RRect.fromRectAndRadius(b.rect, const Radius.circular(2)),
        paint,
      );
    }
  }

  // ── Enemies ───────────────────────────────────────────────────────────────────

  void _drawEnemies(Canvas canvas, Size size) {
    for (final e in engine.enemies) {
      if (!e.isAlive) continue;
      switch (e.type) {
        case EnemyType.wave:
          _drawWaveEnemy(canvas, e);
        case EnemyType.random:
          _drawRandomEnemy(canvas, e);
        case EnemyType.boss:
          _drawBoss(canvas, e, size);
      }
    }
  }

  void _drawWaveEnemy(Canvas canvas, Enemy e) {
    final r = RRect.fromRectAndRadius(e.rect, const Radius.circular(4));
    canvas.drawRRect(r, _waveEnemyPaint);
    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF0A1A0A);
    canvas.drawCircle(Offset(e.x - 7, e.y - 3), 3, eyePaint);
    canvas.drawCircle(Offset(e.x + 7, e.y - 3), 3, eyePaint);
    // Antenna
    final antPaint = Paint()
      ..color = const Color(0xFF69F0AE)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(e.x - 8, e.y - e.height / 2), Offset(e.x - 8, e.y - e.height / 2 - 6), antPaint);
    canvas.drawLine(Offset(e.x + 8, e.y - e.height / 2), Offset(e.x + 8, e.y - e.height / 2 - 6), antPaint);
  }

  void _drawRandomEnemy(Canvas canvas, Enemy e) {
    // Diamond shape
    final path = Path()
      ..moveTo(e.x, e.y - e.height / 2)
      ..lineTo(e.x + e.width / 2, e.y)
      ..lineTo(e.x, e.y + e.height / 2)
      ..lineTo(e.x - e.width / 2, e.y)
      ..close();
    canvas.drawPath(path, _randomEnemyPaint);
    // Inner diamond
    final innerPaint = Paint()
      ..color = const Color(0xFFFFD080)
      ..style = PaintingStyle.fill;
    final inner = Path()
      ..moveTo(e.x, e.y - 6)
      ..lineTo(e.x + 6, e.y)
      ..lineTo(e.x, e.y + 6)
      ..lineTo(e.x - 6, e.y)
      ..close();
    canvas.drawPath(inner, innerPaint);
  }

  void _drawBoss(Canvas canvas, Enemy e, Size size) {
    final r = e.rect;

    // Shadow glow
    final glowPaint = Paint()
      ..color = const Color(0xFFE05C5C).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r.inflate(8), const Radius.circular(10)),
      glowPaint,
    );

    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      _bossPaint,
    );

    // Top stripe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r.left + 8, r.top + 8, r.width - 16, 8),
        const Radius.circular(3),
      ),
      _bossDetailPaint,
    );

    // Cannon tips
    final cannonPaint = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r.left + 10, r.bottom - 4, 10, 8),
        const Radius.circular(2),
      ),
      cannonPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r.right - 20, r.bottom - 4, 10, 8),
        const Radius.circular(2),
      ),
      cannonPaint,
    );

    // Health bar
    const barH  = 6.0;
    const barW  = 80.0;
    final barX  = e.x - barW / 2;
    final barY  = r.bottom + 10;
    final ratio = (e.health / e.maxHealth).clamp(0.0, 1.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barW, barH),
        const Radius.circular(3),
      ),
      _healthBgPaint,
    );
    if (ratio > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barW * ratio, barH),
          const Radius.circular(3),
        ),
        _healthFillPaint,
      );
    }

    // HP text
    final tPainter = TextPainter(
      text: TextSpan(
        text: '${e.health} / ${e.maxHealth}',
        style: const TextStyle(
          color: Color(0xFFFF8080),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tPainter.paint(
      canvas,
      Offset(e.x - tPainter.width / 2, barY + barH + 3),
    );
  }

  // ── Player ────────────────────────────────────────────────────────────────────

  void _drawPlayer(Canvas canvas, int tick) {
    // Blink when invincible
    if (engine.player.isInvincible && (tick ~/ 4) % 2 == 0) return;

    final x = engine.player.x;
    final y = engine.player.y;
    const w = Player.width;
    const h = Player.height;

    // Ship body (chevron)
    final body = Path()
      ..moveTo(x, y - h * 0.48)           // nose
      ..lineTo(x + w * 0.48, y + h * 0.48) // bottom-right
      ..lineTo(x + w * 0.12, y + h * 0.18) // inner-right notch
      ..lineTo(x, y + h * 0.32)            // center rear
      ..lineTo(x - w * 0.12, y + h * 0.18) // inner-left notch
      ..lineTo(x - w * 0.48, y + h * 0.48) // bottom-left
      ..close();
    canvas.drawPath(body, _playerPaint);

    // Cockpit
    final cockpitPaint = Paint()..color = const Color(0xFFFFA07A);
    canvas.drawCircle(Offset(x, y - 4), 5, cockpitPaint);

    // Engine glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y + h * 0.5 + 4),
        width: 16,
        height: 8,
      ),
      glowPaint,
    );
  }

  // ── Explosions ────────────────────────────────────────────────────────────────

  void _drawExplosions(Canvas canvas) {
    for (final ex in engine.explosions) {
      final outerPaint = Paint()
        ..color = const Color(0xFFFF6B00).withOpacity(ex.opacity * 0.6);
      final innerPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(ex.opacity);

      canvas.drawCircle(Offset(ex.x, ex.y), ex.currentRadius, outerPaint);
      canvas.drawCircle(
        Offset(ex.x, ex.y),
        ex.currentRadius * 0.5,
        innerPaint,
      );
    }
  }
}
