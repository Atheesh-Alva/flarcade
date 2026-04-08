import 'difficulty.dart';

class GameInfo {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Difficulty difficulty;

  /// The go_router path for this game, e.g. '/snake'.
  /// Null means the game hasn't been built yet.
  final String? route;

  const GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.difficulty,
    this.route,
  });

  bool get isAvailable => route != null;
}
