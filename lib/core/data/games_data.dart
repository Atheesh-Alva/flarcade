import '../models/difficulty.dart';
import '../models/game_info.dart';

/// Master catalogue — flip [route] from null to a path string
/// once a game's screen is built and registered in router.dart.
const List<GameInfo> kGames = [
  // ── Easy ────────────────────────────────────────────────────
  GameInfo(
    id: 'number_guess',
    title: 'Number Guess',
    description: 'Higher or lower — can you crack the number?',
    emoji: '🎲',
    difficulty: Difficulty.easy,
    route: '/number-guess',
  ),
  GameInfo(
    id: 'quiz',
    title: 'Quiz Blitz',
    description: 'Race the clock across rapid-fire trivia.',
    emoji: '🧠',
    difficulty: Difficulty.easy,
    route: null,
  ),
  GameInfo(
    id: 'tictactoe',
    title: 'Tic-Tac-Toe',
    description: 'The timeless X vs O face-off.',
    emoji: '⊞',
    difficulty: Difficulty.easy,
    route: null,
  ),
  GameInfo(
    id: 'rps',
    title: 'Rock Paper Scissors',
    description: 'Outsmart the machine in three moves.',
    emoji: '✊',
    difficulty: Difficulty.easy,
    route: null,
  ),
  GameInfo(
    id: 'memory',
    title: 'Memory Match',
    description: 'Flip cards and find every pair.',
    emoji: '🃏',
    difficulty: Difficulty.easy,
    route: null,
  ),

  // ── Medium ───────────────────────────────────────────────────
  GameInfo(
    id: 'brick_breaker',
    title: 'Brick Breaker',
    description: 'Bounce the ball, smash every brick.',
    emoji: '🧱',
    difficulty: Difficulty.medium,
    route: null,
  ),
  GameInfo(
    id: 'snake',
    title: 'Snake',
    description: 'Eat, grow, and don\'t bite yourself.',
    emoji: '🐍',
    difficulty: Difficulty.medium,
    route: null,
  ),
  GameInfo(
    id: 'flappy',
    title: 'Flappy Bird',
    description: 'One tap. Infinite pipes. Pure chaos.',
    emoji: '🐦',
    difficulty: Difficulty.medium,
    route: null,
  ),
  GameInfo(
    id: 'whack',
    title: 'Whack-a-Mole',
    description: 'Tap fast before they disappear.',
    emoji: '🔨',
    difficulty: Difficulty.medium,
    route: null,
  ),
  GameInfo(
    id: 'runner',
    title: 'Endless Runner',
    description: 'Jump, dodge, and keep running.',
    emoji: '🏃',
    difficulty: Difficulty.medium,
    route: '/endless-runner',
  ),

  // ── Hard ─────────────────────────────────────────────────────
  GameInfo(
    id: 'sudoku',
    title: 'Sudoku',
    description: 'Fill the grid without a single mistake.',
    emoji: '🔢',
    difficulty: Difficulty.hard,
    route: null,
  ),
  GameInfo(
    id: '2048',
    title: '2048',
    description: 'Slide and merge tiles to the top.',
    emoji: '◼',
    difficulty: Difficulty.hard,
    route: null,
  ),
  GameInfo(
    id: 'space_shooter',
    title: 'Space Shooter',
    description: 'Defend the galaxy from endless waves.',
    emoji: '🚀',
    difficulty: Difficulty.hard,
    route: '/space-shooter',
  ),
  GameInfo(
    id: 'slide_puzzle',
    title: 'Slide Puzzle',
    description: 'Rearrange the tiles into order.',
    emoji: '🧩',
    difficulty: Difficulty.hard,
    route: null,
  ),
];
