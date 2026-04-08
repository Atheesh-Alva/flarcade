import 'dart:math';
import '../models/er_models.dart';

enum RunnerPhase { playing, paused, gameOver }

class EndlessRunnerEngine {
  bool initialized = false;
  double _w = 0, _h = 0;
  final _rng = Random();

  // ── Entities ─────────────────────────────────────────────────────────────────
  ErPlayer player = ErPlayer(y: 0);
  final List<GroundSegment> ground = [];
  final List<ErObstacle> obstacles = [];
  final List<ErCloud> clouds = [];
  final List<ErStar> stars = [];

  // ── Game state ───────────────────────────────────────────────────────────────
  RunnerPhase phase = RunnerPhase.playing;
  double distance = 0; // meters
  int bestScore = 0;
  double speed = 220; // px/s

  // ── Day/night cycle ───────────────────────────────────────────────────────────
  double skyTime = 0; // 0..1 over 60s

  // ── Internal ──────────────────────────────────────────────────────────────────
  double _speedTimer = 0;
  double _genX = 0; // rightmost generated x
  static const double _groundY = 0; // set in init

  double get groundY => _h - 72;

  // ── Public API ────────────────────────────────────────────────────────────────

  void init(double w, double h) {
    _w = w;
    _h = h;
    initialized = true;
    _setup();
  }

  void reset() {
    if (!initialized) return;
    _setup();
  }

  void update(double dt) {
    if (!initialized || phase != RunnerPhase.playing) return;

    _updateSpeed(dt);
    _applyPhysics(dt);
    _checkGround();
    _scrollWorld(dt);
    _generateAhead();
    _checkObstacleCollisions();
    _updateInvincibility(dt);
    _updateSlide(dt);
    _updateClouds(dt);
    _updateLegAnimation(dt);
    _updateSkyTime(dt);
    distance += speed * dt / 100; // 100px ≈ 1 metre
  }

  void jump() {
    if (!initialized || phase != RunnerPhase.playing) return;
    if (player.onGround) {
      player.vy = ErPlayer.jumpVy;
      player.onGround = false;
    } else if (player.hasDoubleJump) {
      player.vy = ErPlayer.jumpVy * 0.88;
      player.hasDoubleJump = false;
    }
  }

  void startSlide() {
    if (!initialized || phase != RunnerPhase.playing) return;
    if (!player.isSliding) {
      player.isSliding = true;
      player.slideTimer = ErPlayer.slideDuration;
      // Reposition y so bottom stays on ground when sliding
      if (player.onGround) {
        player.y = groundY - ErPlayer.slideHeight;
      }
    }
  }

  void togglePause() {
    if (phase == RunnerPhase.playing) {
      phase = RunnerPhase.paused;
    } else if (phase == RunnerPhase.paused) {
      phase = RunnerPhase.playing;
    }
  }

  // ── Setup ─────────────────────────────────────────────────────────────────────

  void _setup() {
    ground.clear();
    obstacles.clear();
    clouds.clear();
    phase = RunnerPhase.playing;
    distance = 0;
    speed = 220;
    skyTime = 0.25; // start at dawn
    _speedTimer = 0;

    player = ErPlayer(y: groundY - ErPlayer.standHeight);

    // Initial solid ground
    ground.add(GroundSegment(x: 0, width: _w + 400));
    _genX = _w + 400;

    _spawnClouds();
    _generateAhead();
  }

  void _spawnClouds() {
    for (int i = 0; i < 5; i++) {
      clouds.add(ErCloud(
        x: _rng.nextDouble() * _w,
        y: 30 + _rng.nextDouble() * (_h * 0.35),
        speed: 20 + _rng.nextDouble() * 30,
        scale: 0.6 + _rng.nextDouble() * 0.8,
      ));
    }
    // Generate stars for night sky (fixed positions)
    stars.clear();
    for (int i = 0; i < 60; i++) {
      stars.add(ErStar(
        x: _rng.nextDouble() * _w,
        y: _rng.nextDouble() * groundY * 0.85,
        size: 0.5 + _rng.nextDouble() * 1.5,
        opacity: 0.4 + _rng.nextDouble() * 0.6,
      ));
    }
  }

  // ── Physics ───────────────────────────────────────────────────────────────────

  void _applyPhysics(double dt) {
    if (!player.onGround) {
      player.vy += ErPlayer.gravity * dt;
    }
    player.y += player.vy * dt;

    // Terminal velocity
    player.vy = player.vy.clamp(-900.0, 900.0);
  }

  void _checkGround() {
    final bottom = player.bottom;

    // Check if over a ground segment
    bool overGround = false;
    for (final seg in ground) {
      if (ErPlayer.fixedX >= seg.x && ErPlayer.fixedX <= seg.x + seg.width) {
        overGround = true;
        break;
      }
    }

    if (overGround && bottom >= groundY && player.vy >= 0) {
      player.y = groundY - player.currentHeight;
      player.vy = 0;
      player.onGround = true;
      player.hasDoubleJump = true;
    } else if (!overGround && bottom >= groundY) {
      // Over a pit — let player fall
      player.onGround = false;
      if (player.y > _h + 20) {
        _triggerGameOver();
      }
    } else if (bottom < groundY) {
      player.onGround = false;
    }
  }

  // ── World scrolling ───────────────────────────────────────────────────────────

  void _scrollWorld(double dt) {
    final dx = speed * dt;

    for (final seg in ground) {
      seg.x -= dx;
    }
    for (final obs in obstacles) {
      obs.x -= dx;
    }
    _genX -= dx;

    // Prune off-screen
    ground.removeWhere((s) => s.x + s.width < -50);
    obstacles.removeWhere((o) => o.x + o.width < -50);
  }

  // ── World generation ──────────────────────────────────────────────────────────

  void _generateAhead() {
    // Keep ~2 screens ahead generated
    while (_genX < _w + 600) {
      if (distance < 5) {
        // Grace zone: no obstacles, solid ground
        _addGround(400);
      } else {
        _generateChunk();
      }
    }
  }

  void _generateChunk() {
    // Roll for gap or solid ground
    final hasPit = distance > 15 && _rng.nextDouble() < 0.3;

    if (hasPit) {
      // Pit: no ground for 90-130px
      final pitWidth = 90.0 + _rng.nextDouble() * 40;
      _genX += pitWidth;
      // Small platform after pit sometimes
      _addGround(180 + _rng.nextDouble() * 120);
    } else {
      _addGround(200 + _rng.nextDouble() * 200);
    }

    // Spawn obstacle on the last ground segment
    if (distance > 8 && _rng.nextDouble() < 0.6) {
      _spawnObstacle();
    }
  }

  void _addGround(double width) {
    ground.add(GroundSegment(x: _genX, width: width));
    _genX += width;
  }

  void _spawnObstacle() {
    // Place obstacle at the start of the newly added segment (with buffer)
    final obsX = _genX - 60 - _rng.nextDouble() * 80;

    final roll = _rng.nextDouble();
    if (roll < 0.38) {
      obstacles.add(ErObstacle.block(x: obsX, groundY: groundY));
    } else if (roll < 0.70) {
      obstacles.add(ErObstacle.spike(x: obsX, groundY: groundY));
    } else {
      // Aerial bar only when player has had a chance to learn sliding
      if (distance > 20) {
        obstacles.add(ErObstacle.aerialBar(x: obsX, groundY: groundY));
      } else {
        obstacles.add(ErObstacle.block(x: obsX, groundY: groundY));
      }
    }
  }

  // ── Collisions ────────────────────────────────────────────────────────────────

  void _checkObstacleCollisions() {
    if (player.isInvincible) return;
    for (final obs in obstacles) {
      if (player.rect.overlaps(obs.rect)) {
        _triggerGameOver();
        return;
      }
    }
  }

  void _triggerGameOver() {
    phase = RunnerPhase.gameOver;
    if (distance > bestScore) bestScore = distance.toInt();
  }

  // ── Timers ────────────────────────────────────────────────────────────────────

  void _updateSpeed(double dt) {
    _speedTimer += dt;
    if (_speedTimer >= 5) {
      _speedTimer = 0;
      speed = min(speed + 10, 450);
    }
  }

  void _updateSlide(double dt) {
    if (!player.isSliding) return;
    player.slideTimer -= dt;
    if (player.slideTimer <= 0) {
      player.isSliding = false;
      player.slideTimer = 0;
      // Restore standing position if on ground
      if (player.onGround) {
        player.y = groundY - ErPlayer.standHeight;
      }
    }
  }

  void _updateInvincibility(double dt) {
    if (!player.isInvincible) return;
    player.invincibleTimer -= dt;
    if (player.invincibleTimer <= 0) {
      player.isInvincible = false;
      player.invincibleTimer = 0;
    }
  }

  void _updateLegAnimation(double dt) {
    if (!player.onGround) return;
    player.legTimer += dt;
    if (player.legTimer >= 0.18) {
      player.legTimer = 0;
      player.legFrame = player.legFrame == 0 ? 1 : 0;
    }
  }

  void _updateClouds(double dt) {
    for (final c in clouds) {
      c.x -= c.speed * dt;
      if (c.x + 80 * c.scale < 0) {
        c.x = _w + 20;
      }
    }
  }

  void _updateSkyTime(double dt) {
    skyTime += dt / 60.0; // full cycle = 60s
    if (skyTime >= 1.0) skyTime -= 1.0;
  }

  // ── Sky interpolation helpers ─────────────────────────────────────────────────

  /// Returns 0..3 phase index + fractional blend (0..1)
  (int phaseIndex, double blend) get skyPhase {
    final t = skyTime * 4; // 0..4
    final idx = t.floor() % 4;
    final blend = t - t.floor();
    return (idx, blend);
  }
}
