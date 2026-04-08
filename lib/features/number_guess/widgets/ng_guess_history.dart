import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/guess_result.dart';

class NgGuessHistory extends StatelessWidget {
  final List<GuessResult> history;

  const NgGuessHistory({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HISTORY', style: AppTheme.labelCaps),
          const SizedBox(height: 10),
          // Show most recent first
          ...history.reversed.toList().asMap().entries.map(
                (e) => _HistoryRow(
                  result: e.value,
                  attemptNumber: history.length - e.key,
                ),
              ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final GuessResult result;
  final int attemptNumber;

  const _HistoryRow({required this.result, required this.attemptNumber});

  Color get _hintColor {
    switch (result.hint) {
      case GuessHint.tooHigh: return const Color(0xFFE05C5C);
      case GuessHint.tooLow:  return const Color(0xFFE8A838);
      case GuessHint.correct: return const Color(0xFF4CAF82);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Attempt number
          SizedBox(
            width: 28,
            child: Text(
              '#$attemptNumber',
              style: AppTheme.cardBody.copyWith(fontSize: 11),
            ),
          ),

          // Guess value
          Text(
            '${result.value}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(width: 8),

          // Hint pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _hintColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: _hintColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result.hint.arrow,
                  style: TextStyle(fontSize: 11, color: _hintColor),
                ),
                const SizedBox(width: 4),
                Text(
                  result.hint.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _hintColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
