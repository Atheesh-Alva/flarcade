import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guess_result.dart';
import '../models/number_guess_state.dart';

class NumberGuessNotifier extends Notifier<NumberGuessState> {
  final _rng = Random();

  @override
  NumberGuessState build() => _freshState();

  // ── Public API ────────────────────────────────────────────────

  /// Increment or decrement the current guess, clamped to 1–100.
  void adjustGuess(int delta) {
    if (!state.isPlaying) return;
    final next = (state.currentGuess + delta).clamp(1, 100);
    state = state.copyWith(currentGuess: next);
  }

  /// Directly set the guess value (from a text field).
  void setGuess(int value) {
    if (!state.isPlaying) return;
    state = state.copyWith(currentGuess: value.clamp(1, 100));
  }

  /// Evaluate the current guess against the secret number.
  void submitGuess() {
    if (!state.isPlaying) return;

    final guess  = state.currentGuess;
    final secret = state.secretNumber;

    final hint = guess == secret
        ? GuessHint.correct
        : guess > secret
            ? GuessHint.tooHigh
            : GuessHint.tooLow;

    final newHistory = [...state.history, GuessResult(value: guess, hint: hint)];
    final newAttemptsLeft = state.attemptsLeft - 1;
    final newScore = hint == GuessHint.correct
        ? state.score
        : (state.score - NumberGuessState.penaltyPerWrongGuess).clamp(0, 700);

    GameStatus newStatus = GameStatus.playing;
    if (hint == GuessHint.correct) {
      newStatus = GameStatus.won;
    } else if (newAttemptsLeft == 0) {
      newStatus = GameStatus.lost;
    }

    state = state.copyWith(
      history:      newHistory,
      attemptsLeft: newAttemptsLeft,
      score:        newScore,
      status:       newStatus,
    );
  }

  /// Start a brand new game.
  void resetGame() => state = _freshState();

  // ── Private ────────────────────────────────────────────────────

  NumberGuessState _freshState() => NumberGuessState(
        secretNumber: _rng.nextInt(100) + 1,
      );
}

// ── Provider ───────────────────────────────────────────────────────────────────

final numberGuessProvider =
    NotifierProvider<NumberGuessNotifier, NumberGuessState>(
  NumberGuessNotifier.new,
);
