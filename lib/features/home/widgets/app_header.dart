import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo row ──
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    '▶',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'FlutterArcade',
                style: AppTheme.displayLarge.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── Headline ──
          const Text(
            'Your pocket\ngame collection.',
            style: AppTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            '14 games across 3 difficulty levels.',
            style: AppTheme.cardBody,
          ),
        ],
      ),
    );
  }
}
