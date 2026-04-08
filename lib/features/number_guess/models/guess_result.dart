enum GuessHint { tooHigh, tooLow, correct }

extension GuessHintX on GuessHint {
  String get label {
    switch (this) {
      case GuessHint.tooHigh: return 'Too high';
      case GuessHint.tooLow:  return 'Too low';
      case GuessHint.correct: return 'Correct!';
    }
  }

  String get arrow {
    switch (this) {
      case GuessHint.tooHigh: return '↑';
      case GuessHint.tooLow:  return '↓';
      case GuessHint.correct: return '✓';
    }
  }
}

class GuessResult {
  final int value;
  final GuessHint hint;

  const GuessResult({required this.value, required this.hint});
}
