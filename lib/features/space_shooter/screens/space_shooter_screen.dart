import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/ss_engine.dart';
import '../providers/ss_provider.dart';
import '../rendering/game_painter.dart';
import '../widgets/ss_controls.dart';
import '../widgets/ss_header.dart';
import '../widgets/ss_result_overlay.dart';

class SpaceShooterScreen extends ConsumerStatefulWidget {
  const SpaceShooterScreen({super.key});

  @override
  ConsumerState<SpaceShooterScreen> createState() =>
      _SpaceShooterScreenState();
}

class _SpaceShooterScreenState extends ConsumerState<SpaceShooterScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _initialized = false;

  final _gameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    // Clamp dt to avoid huge jumps after pauses
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    final clampedDt = min(dt, 0.05);

    // Initialize engine once we have the game area size
    if (!_initialized) {
      final box =
          _gameKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.width > 0) {
        ref
            .read(spaceShooterProvider.notifier)
            .init(box.size.width, box.size.height);
        _initialized = true;
      }
      return;
    }

    final engine = ref.read(spaceShooterProvider).engine;
    if (engine.phase == GamePhase.playing) {
      ref.read(spaceShooterProvider.notifier).tick(clampedDt);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(spaceShooterProvider);
    final engine  = state.engine;
    final notifier = ref.read(spaceShooterProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF060912),
      body: SafeArea(
        child: Column(
          children: [
            // ── HUD ──────────────────────────────────────────────
            SsHeader(
              engine: engine,
              onPause: () {
                notifier.togglePause();
                // Show pause overlay via rebuild
              },
            ),

            // ── Game area + gesture controls ──────────────────
            Expanded(
              child: Stack(
                children: [
                  // Game canvas
                  SizedBox.expand(
                    key: _gameKey,
                    child: CustomPaint(
                      painter: GamePainter(
                        engine: engine,
                        tick: state.tick,
                      ),
                    ),
                  ),

                  // Gesture control zone (behind overlays)
                  if (engine.phase == GamePhase.playing)
                    Positioned.fill(
                      child: SsControls(
                        onLeftStart:  notifier.startMoveLeft,
                        onLeftEnd:    notifier.stopMoveLeft,
                        onRightStart: notifier.startMoveRight,
                        onRightEnd:   notifier.stopMoveRight,
                      ),
                    ),

                  // Pause overlay
                  if (engine.phase == GamePhase.paused)
                    SsResultOverlay(
                      engine: engine,
                      onPlayAgain: notifier.togglePause,
                    ),

                  // Game over overlay
                  if (engine.phase == GamePhase.gameOver)
                    SsResultOverlay(
                      engine: engine,
                      onPlayAgain: () {
                        notifier.reset();
                        _initialized = false;
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
