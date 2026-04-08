import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class NgHeader extends StatelessWidget {
  final int score;
  final int attemptsLeft;
  final int maxAttempts;

  const NgHeader({
    super.key,
    required this.score,
    required this.attemptsLeft,
    required this.maxAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border(
          bottom: BorderSide(color: AppTheme.inkFaint, width: 1),
        ),
      ),
      child: Row(
        children: [
          // ── Back ──
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.ink,
            onPressed: () => context.go('/'),
          ),

          // ── Title ──
          const Expanded(
            child: Text(
              'Number Guess',
              style: AppTheme.cardTitle,
            ),
          ),

          // ── Score ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const Text('score', style: AppTheme.cardBody),
            ],
          ),
          const SizedBox(width: 16),

          // ── Attempts pill ──
          _AttemptsPill(
            attemptsLeft: attemptsLeft,
            maxAttempts: maxAttempts,
          ),
        ],
      ),
    );
  }
}

class _AttemptsPill extends StatelessWidget {
  final int attemptsLeft;
  final int maxAttempts;

  const _AttemptsPill({
    required this.attemptsLeft,
    required this.maxAttempts,
  });

  Color get _color {
    if (attemptsLeft >= 5) return const Color(0xFF4CAF82);
    if (attemptsLeft >= 3) return const Color(0xFFE8A838);
    return const Color(0xFFE05C5C);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$attemptsLeft left',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
