import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/games_data.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/home_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/difficulty_filter.dart';
import '../widgets/game_card.dart';
import '../widgets/game_search_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final games = state.filteredGames;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────
            const SliverToBoxAdapter(child: AppHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Search ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GameSearchBar(
                  onChanged: notifier.updateSearch,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Difficulty filter ─────────────────────────────────
            SliverToBoxAdapter(
              child: DifficultyFilter(
                selected: state.selectedDifficulty,
                onSelect: notifier.selectDifficulty,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Section label ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Text('GAMES', style: AppTheme.labelCaps),
                    const Spacer(),
                    Text(
                      '${games.length} of ${kGames.length}',
                      style: AppTheme.labelCaps,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Game grid or empty state ───────────────────────────
            games.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.76,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) =>
                            GameCard(game: games[i], index: i),
                        childCount: games.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎮', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'No games found',
            style: AppTheme.cardBody.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
