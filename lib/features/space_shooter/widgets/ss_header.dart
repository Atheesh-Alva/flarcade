import 'package:flutter/material.dart';
import '../engine/ss_engine.dart';

class SsHeader extends StatelessWidget {
  final SpaceShooterEngine engine;
  final VoidCallback onPause;

  const SsHeader({
    super.key,
    required this.engine,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: const Color(0xFF0A0D1A),
      child: Row(
        children: [
          // ── Back / pause ──
          GestureDetector(
            onTap: onPause,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Icon(
                engine.phase == GamePhase.paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: Colors.white54,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Score ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${engine.score}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
                Text(
                  'SCORE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.35),
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ── Wave ──
          _StatPill(
            label: 'WAVE',
            value: '${engine.wave}',
            color: const Color(0xFF4CAF82),
          ),
          const SizedBox(width: 10),

          // ── Lives ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final active = engine.initialized && i < engine.player.lives;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: active
                      ? const Color(0xFFE05C5C)
                      : Colors.white.withOpacity(0.15),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
