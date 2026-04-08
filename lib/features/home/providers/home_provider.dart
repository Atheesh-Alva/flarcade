import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/games_data.dart';
import '../../../core/models/difficulty.dart';
import '../../../core/models/game_info.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class HomeState {
  final String searchQuery;
  final Difficulty? selectedDifficulty;
  final List<GameInfo> filteredGames;

  const HomeState({
    this.searchQuery = '',
    this.selectedDifficulty,
    required this.filteredGames,
  });

  HomeState copyWith({
    String? searchQuery,
    Difficulty? Function()? selectedDifficulty,
    List<GameInfo>? filteredGames,
  }) {
    return HomeState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDifficulty: selectedDifficulty != null
          ? selectedDifficulty()
          : this.selectedDifficulty,
      filteredGames: filteredGames ?? this.filteredGames,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState(filteredGames: kGames);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void selectDifficulty(Difficulty? difficulty) {
    // Tapping the already-selected difficulty deselects it
    final next = state.selectedDifficulty == difficulty ? null : difficulty;
    state = state.copyWith(selectedDifficulty: () => next);
    _applyFilters();
  }

  void _applyFilters() {
    final query = state.searchQuery.toLowerCase();
    final diff = state.selectedDifficulty;

    final filtered = kGames.where((g) {
      final matchesSearch =
          query.isEmpty || g.title.toLowerCase().contains(query);
      final matchesDiff = diff == null || g.difficulty == diff;
      return matchesSearch && matchesDiff;
    }).toList();

    state = state.copyWith(filteredGames: filtered);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
