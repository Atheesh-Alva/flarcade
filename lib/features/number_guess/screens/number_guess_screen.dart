import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/number_guess_state.dart';
import '../providers/number_guess_provider.dart';
import '../widgets/ng_header.dart';
import '../widgets/ng_hint_banner.dart';
import '../widgets/ng_number_input.dart';
import '../widgets/ng_guess_history.dart';
import '../widgets/ng_result_overlay.dart';

class NumberGuessScreen extends ConsumerWidget {
  const NumberGuessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(numberGuessProvider);
    final notifier = ref.read(numberGuessProvider.notifier);
    final lastGuess = state.history.isEmpty ? null : state.history.last;

    return Scaffold(
      body: Stack(
        children: [
          // ── Game body ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                NgHeader(
                  score: state.score,
                  attemptsLeft: state.attemptsLeft,
                  maxAttempts: NumberGuessState.maxAttempts,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hint banner
                        NgHintBanner(lastGuess: lastGuess),
                        const SizedBox(height: 32),

                        // Number input + submit
                        NgNumberInput(
                          value: state.currentGuess,
                          enabled: state.isPlaying,
                          onAdjust: notifier.adjustGuess,
                          onChanged: notifier.setGuess,
                          onSubmit: notifier.submitGuess,
                        ),
                        const SizedBox(height: 32),

                        // History
                        NgGuessHistory(history: state.history),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Result overlay (shown when game ends) ──────────────
          if (state.status != GameStatus.playing)
            Positioned.fill(
              child: NgResultOverlay(
                status: state.status,
                score: state.score,
                secretNumber: state.secretNumber,
                totalGuesses: state.history.length,
                onPlayAgain: notifier.resetGame,
              ),
            ),
        ],
      ),
    );
  }
}
