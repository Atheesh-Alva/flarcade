import 'package:flutter/material.dart';
import 'package:flutter_arcade/core/models/difficulty.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/game_info.dart';
import '../../../core/theme/app_theme.dart';

class GameBottomSheet extends StatelessWidget {
  final GameInfo game;

  const GameBottomSheet({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final diffColor = game.difficulty.color;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.inkFaint),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──
          Center(
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.inkFaint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Emoji + difficulty badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.emoji, style: const TextStyle(fontSize: 44)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: diffColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: diffColor.withOpacity(0.3)),
                ),
                child: Text(
                  game.difficulty.label,
                  style: AppTheme.tagLabel.copyWith(
                    color: diffColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Title & description ──
          Text(
            game.title,
            style: AppTheme.displayLarge.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            game.description,
            style: AppTheme.cardBody.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 32),
          Divider(color: AppTheme.inkFaint, height: 1),
          const SizedBox(height: 24),

          // ── Play / Coming soon button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    game.isAvailable ? AppTheme.ink : AppTheme.inkFaint,
                foregroundColor:
                    game.isAvailable ? Colors.white : AppTheme.inkMuted,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (game.isAvailable) {
                  context.go(game.route!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${game.title} coming soon!'),
                      backgroundColor: AppTheme.ink,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    game.isAvailable ? 'Play' : 'Coming soon',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (game.isAvailable) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.play_arrow_rounded, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
