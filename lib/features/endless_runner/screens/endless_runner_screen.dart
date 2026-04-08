import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/er_engine.dart';
import '../providers/er_provider.dart';
import '../rendering/er_painter.dart';
import '../widgets/er_hud.dart';
import '../widgets/er_result_overlay.dart';

class EndlessRunnerScreen extends ConsumerStatefulWidget {
  const EndlessRunnerScreen({super.key});

  @override
  ConsumerState<EndlessRunnerScreen> createState() =>
      _EndlessRunnerScreenState();
}

class _EndlessRunnerScreenState extends ConsumerState<EndlessRunnerScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _initialized     = false;

  final _gameKey = GlobalKey();

  // Gesture tracking for swipe detection
  double _dragStartY = 0;
  double _dragCurrentY = 0;
  bool   _swipeConsumed = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    final clampedDt = min(dt, 0.05);

    if (!_initialized) {
      final box =
          _gameKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.width > 0) {
        ref.read(endlessRunnerProvider.notifier)
            .init(box.size.width, box.size.height);
        _initialized = true;
      }
      return;
    }

    final engine = ref.read(endlessRunnerProvider).engine;
    if (engine.phase == RunnerPhase.playing) {
      ref.read(endlessRunnerProvider.notifier).tick(clampedDt);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ── Gesture handlers ──────────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails _) {
    final engine = ref.read(endlessRunnerProvider).engine;
    if (engine.phase == RunnerPhase.playing) {
      ref.read(endlessRunnerProvider.notifier).jump();
    }
  }

  void _onDragStart(DragStartDetails d) {
    _dragStartY   = d.localPosition.dy;
    _dragCurrentY = d.localPosition.dy;
    _swipeConsumed = false;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_swipeConsumed) return;
    _dragCurrentY = d.localPosition.dy;

    final dy = _dragCurrentY - _dragStartY;
    final engine = ref.read(endlessRunnerProvider).engine;
    if (engine.phase != RunnerPhase.playing) return;

    if (dy < -40) {
      // Swipe up → jump
      ref.read(endlessRunnerProvider.notifier).jump();
      _swipeConsumed = true;
    } else if (dy > 40) {
      // Swipe down → slide
      ref.read(endlessRunnerProvider.notifier).slide();
      _swipeConsumed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(endlessRunnerProvider);
    final engine   = state.engine;
    final notifier = ref.read(endlessRunnerProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          // ── Game canvas ──────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown:             _onTapDown,
            onVerticalDragStart:   _onDragStart,
            onVerticalDragUpdate:  _onDragUpdate,
            child: SizedBox.expand(
              key: _gameKey,
              child: CustomPaint(
                painter: ErPainter(
                  engine: engine,
                  tick:   state.tick,
                ),
              ),
            ),
          ),

          // ── HUD (overlaid on canvas) ──────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: ErHud(
              engine:  engine,
              onPause: notifier.togglePause,
            ),
          ),

          // ── Control hint (first 5 metres) ─────────────────────────
          if (engine.initialized && engine.distance < 5)
            Positioned(
              bottom: 40,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Tap to jump · swipe down to slide',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // ── Pause overlay ────────────────────────────────────────
          if (engine.phase == RunnerPhase.paused)
            Positioned.fill(
              child: ErResultOverlay(
                engine: engine,
                onPlayAgain: notifier.togglePause,
              ),
            ),

          // ── Game over overlay ────────────────────────────────────
          if (engine.phase == RunnerPhase.gameOver)
            Positioned.fill(
              child: ErResultOverlay(
                engine: engine,
                onPlayAgain: () {
                  notifier.reset();
                  _initialized = false;
                },
              ),
            ),
        ],
      ),
    );
  }
}
