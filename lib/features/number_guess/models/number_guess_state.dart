import 'guess_result.dart';

enum GameStatus { playing, won, lost }

class NumberGuessState {
  final int secretNumber;
  final int currentGuess;
  final List<GuessResult> history;
  final int attemptsLeft;
  final int score;
  final GameStatus status;

  static const int maxAttempts = 7;
  static const int startScore  = 700;
  static const int penaltyPerWrongGuess = 100;

  const NumberGuessState({
    required this.secretNumber,
    this.currentGuess    = 50,
    this.history         = const [],
    this.attemptsLeft    = maxAttempts,
    this.score           = startScore,
    this.status          = GameStatus.playing,
  });

  bool get isPlaying => status == GameStatus.playing;

  NumberGuessState copyWith({
    int? secretNumber,
    int? currentGuess,
    List<GuessResult>? history,
    int? attemptsLeft,
    int? score,
    GameStatus? status,
  }) {
    return NumberGuessState(
      secretNumber:  secretNumber  ?? this.secretNumber,
      currentGuess:  currentGuess  ?? this.currentGuess,
      history:       history       ?? this.history,
      attemptsLeft:  attemptsLeft  ?? this.attemptsLeft,
      score:         score         ?? this.score,
      status:        status        ?? this.status,
    );
  }
}
