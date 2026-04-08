import 'package:flutter/material.dart';
import '../engine/er_engine.dart';

class ErHud extends StatelessWidget {
  final EndlessRunnerEngine engine;
  final VoidCallback onPause;

  const ErHud({super.key, required this.engine, required this.onPause});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Score ──
            _PixelStat(
              label: 'DIST',
              value: '${engine.distance.toInt()}m',
            ),
            const SizedBox(width: 12),
            _PixelStat(
              label: 'BEST',
              value: '${engine.bestScore}m',
            ),

            const Spacer(),

            // ── Pause ──
            GestureDetector(
              onTap: onPause,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  engine.phase == RunnerPhase.paused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelStat extends StatelessWidget {
  final String label, value;
  const _PixelStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
