import 'package:go_router/go_router.dart';
import '../features/home/screens/home_screen.dart';
import '../features/number_guess/screens/number_guess_screen.dart';
import '../features/space_shooter/screens/space_shooter_screen.dart';
import '../features/endless_runner/screens/endless_runner_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/number-guess',
        builder: (context, state) => const NumberGuessScreen(),
      ),
      GoRoute(
        path: '/space-shooter',
        builder: (context, state) => const SpaceShooterScreen(),
      ),
      GoRoute(
        path: '/endless-runner',
        builder: (context, state) => const EndlessRunnerScreen(),
      ),

      // ── Uncomment as each game is built ───────────────────────
      // GoRoute(path: '/quiz',          builder: (c, s) => const QuizScreen()),
      // GoRoute(path: '/tictactoe',     builder: (c, s) => const TicTacToeScreen()),
      // GoRoute(path: '/rps',           builder: (c, s) => const RpsScreen()),
      // GoRoute(path: '/memory',        builder: (c, s) => const MemoryScreen()),
      // GoRoute(path: '/brick-breaker', builder: (c, s) => const BrickBreakerScreen()),
      // GoRoute(path: '/snake',         builder: (c, s) => const SnakeScreen()),
      // GoRoute(path: '/flappy',        builder: (c, s) => const FlappyScreen()),
      // GoRoute(path: '/whack-a-mole',  builder: (c, s) => const WhackAMoleScreen()),
      // GoRoute(path: '/sudoku',        builder: (c, s) => const SudokuScreen()),
      // GoRoute(path: '/2048',          builder: (c, s) => const Game2048Screen()),
      // GoRoute(path: '/slide-puzzle',  builder: (c, s) => const SlidePuzzleScreen()),
    ],
  );
}
