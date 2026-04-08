import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/er_engine.dart';
import '../models/er_state.dart';

class EndlessRunnerNotifier extends Notifier<EndlessRunnerState> {
  @override
  EndlessRunnerState build() =>
      EndlessRunnerState(engine: EndlessRunnerEngine());

  void init(double w, double h) {
    state.engine.init(w, h);
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

  void jump()       => state.engine.jump();
  void slide()      => state.engine.startSlide();
  void togglePause() {
    state.engine.togglePause();
    state = state.nextTick();
  }
}

final endlessRunnerProvider =
    NotifierProvider<EndlessRunnerNotifier, EndlessRunnerState>(
  EndlessRunnerNotifier.new,
);
