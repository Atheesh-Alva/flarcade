import 'package:flutter/material.dart';

enum Difficulty { easy, medium, hard }

extension DifficultyX on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:   return 'Easy';
      case Difficulty.medium: return 'Medium';
      case Difficulty.hard:   return 'Hard';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:   return const Color(0xFF4CAF82);
      case Difficulty.medium: return const Color(0xFFE8A838);
      case Difficulty.hard:   return const Color(0xFFE05C5C);
    }
  }

  /// Route path prefix — used by the router to navigate to a game.
  String get routeSegment {
    switch (this) {
      case Difficulty.easy:   return 'easy';
      case Difficulty.medium: return 'medium';
      case Difficulty.hard:   return 'hard';
    }
  }
}
