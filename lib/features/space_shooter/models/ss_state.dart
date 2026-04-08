import '../engine/ss_engine.dart';

class SpaceShooterState {
  final SpaceShooterEngine engine;
  final int tick;

  const SpaceShooterState({required this.engine, this.tick = 0});

  SpaceShooterState nextTick() =>
      SpaceShooterState(engine: engine, tick: tick + 1);
}
