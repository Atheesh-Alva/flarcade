import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/ss_engine.dart';
import '../models/ss_state.dart';

class SpaceShooterNotifier extends Notifier<SpaceShooterState> {
  @override
  SpaceShooterState build() =>
      SpaceShooterState(engine: SpaceShooterEngine());

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  void init(double width, double height) {
    state.engine.init(width, height);
    state = state.nextTick();
  }

  void tick(double dt) {
    state.engine.update(dt);
    state = state.nextTick();
  }

  void reset() {
    state.engine.reset();
    state = state.nextTick();
  }

  // ── Controls ─────────────────────────────────────────────────────────────────

  void startMoveLeft()  => state.engine.isMovingLeft  = true;
  void stopMoveLeft()   => state.engine.isMovingLeft  = false;
  void startMoveRight() => state.engine.isMovingRight = true;
  void stopMoveRight()  => state.engine.isMovingRight = false;

  void togglePause() {
    final e = state.engine;
    if (e.phase == GamePhase.playing) {
      e.phase = GamePhase.paused;
    } else if (e.phase == GamePhase.paused) {
      e.phase = GamePhase.playing;
    }
    state = state.nextTick();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final spaceShooterProvider =
    NotifierProvider<SpaceShooterNotifier, SpaceShooterState>(
  SpaceShooterNotifier.new,
);
