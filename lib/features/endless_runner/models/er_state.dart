import '../engine/er_engine.dart';

class EndlessRunnerState {
  final EndlessRunnerEngine engine;
  final int tick;

  const EndlessRunnerState({required this.engine, this.tick = 0});

  EndlessRunnerState nextTick() =>
      EndlessRunnerState(engine: engine, tick: tick + 1);
}
