import 'dart:math';
import '../models/ss_models.dart';

enum GamePhase { playing, paused, gameOver }

class SpaceShooterEngine {
  // ── Init ────────────────────────────────────────────────────────────────────
  bool initialized = false;
  double _w = 0, _h = 0;
  final _rng = Random();

  // ── Entities ─────────────────────────────────────────────────────────────────
  Player player = Player(x: 0, y: 0); // safe default; overwritten in init()
  final List<Bullet>    bullets    = [];
  final List<Enemy>     enemies    = [];
  final List<Explosion> explosions = [];
  final List<Star>      stars      = [];

  // ── Game state ───────────────────────────────────────────────────────────────
  int       score = 0;
  int       wave  = 1;
  int       kills = 0;
  GamePhase phase = GamePhase.playing;

  // ── Controls ─────────────────────────────────────────────────────────────────
  bool isMovingLeft  = false;
  bool isMovingRight = false;

  // ── Internal timers / wave state ─────────────────────────────────────────────
  double _waveVx            = 60.0; // shared horizontal velocity for wave group
  double _randomSpawnTimer  = 2.0;
  double _randomSpawnInterval = 3.0;
  int    _nextBossAt        = 10;   // kill count that triggers next boss
  bool   _bossAlive         = false;

  // ── Public API ───────────────────────────────────────────────────────────────

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
    if (!initialized || phase != GamePhase.playing) return;
    _movePlayer(dt);
    _autoFire(dt);
    _moveBullets(dt);
    _moveWaveEnemies(dt);
    _moveOtherEnemies(dt);
    _spawnRandomEnemy(dt);
    _bossFireLogic(dt);
    _checkCollisions();
    _updateExplosions(dt);
    _scrollStars(dt);
    _checkWaveComplete();
    _checkBossSpawn();
    _updateInvincibility(dt);
  }

  // ── Setup ─────────────────────────────────────────────────────────────────────

  void _setup() {
    bullets.clear();
    enemies.clear();
    explosions.clear();
    stars.clear();
    score = 0;
    wave  = 1;
    kills = 0;
    phase = GamePhase.playing;
    isMovingLeft  = false;
    isMovingRight = false;
    _waveVx             = 60.0;
    _randomSpawnTimer   = 2.0;
    _randomSpawnInterval = 3.0;
    _nextBossAt         = 10;
    _bossAlive          = false;
    player = Player(x: _w / 2, y: _h - 60);
    _spawnStars();
    _spawnWave();
  }

  void _spawnStars() {
    for (int i = 0; i < 70; i++) {
      stars.add(Star(
        x:       _rng.nextDouble() * _w,
        y:       _rng.nextDouble() * _h,
        speed:   20 + _rng.nextDouble() * 60,
        radius:  0.5 + _rng.nextDouble() * 1.5,
        opacity: 0.3 + _rng.nextDouble() * 0.6,
      ));
    }
  }

  void _spawnWave() {
    const cols = 5;
    const rows = 3;
    const spacingX = 58.0;
    const spacingY = 50.0;
    final startX = (_w - (cols - 1) * spacingX) / 2;
    const startY = 80.0;

    // Speed increases each wave
    _waveVx = (60.0 + (wave - 1) * 12.0) * (_rng.nextBool() ? 1 : -1);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        enemies.add(Enemy.wave(
          x:  startX + c * spacingX,
          y:  startY + r * spacingY,
          vx: _waveVx,
        ));
      }
    }
  }

  // ── Player movement ───────────────────────────────────────────────────────────

  void _movePlayer(double dt) {
    if (isMovingLeft) {
      player.x -= Player.speed * dt;
    }
    if (isMovingRight) {
      player.x += Player.speed * dt;
    }
    player.x = player.x.clamp(Player.width / 2, _w - Player.width / 2);
  }

  void _autoFire(double dt) {
    player.fireTimer -= dt;
    if (player.fireTimer <= 0) {
      player.fireTimer = Player.fireInterval;
      bullets.add(Bullet.player(x: player.x, y: player.y - Player.height / 2));
    }
  }

  // ── Bullets ───────────────────────────────────────────────────────────────────

  void _moveBullets(double dt) {
    for (final b in bullets) {
      b.y += b.vy * dt;
    }
    bullets.removeWhere((b) => !b.isAlive || b.y < -20 || b.y > _h + 20);
  }

  // ── Wave enemy movement ───────────────────────────────────────────────────────

  void _moveWaveEnemies(double dt) {
    final waves = enemies.where((e) => e.type == EnemyType.wave && e.isAlive).toList();
    if (waves.isEmpty) return;

    // Check if any would hit a wall after moving
    bool hitLeft  = false;
    bool hitRight = false;
    for (final e in waves) {
      final nx = e.x + _waveVx * dt;
      if (nx - e.width / 2 < 4)        hitLeft  = true;
      if (nx + e.width / 2 > _w - 4)   hitRight = true;
    }

    if ((_waveVx < 0 && hitLeft) || (_waveVx > 0 && hitRight)) {
      // Flip and drop
      _waveVx = -_waveVx;
      for (final e in waves) {
        e.vx = _waveVx;
        e.y += 25;
      }
    } else {
      for (final e in waves) {
        e.x += _waveVx * dt;
        e.vx = _waveVx;
      }
    }

    // Game over if wave enemies reach player
    for (final e in waves) {
      if (e.y + e.height / 2 >= player.y - Player.height / 2) {
        _triggerGameOver();
        return;
      }
    }
  }

  // ── Random + boss movement ────────────────────────────────────────────────────

  void _moveOtherEnemies(double dt) {
    for (final e in enemies) {
      if (e.type == EnemyType.wave || !e.isAlive) continue;
      if (e.type == EnemyType.boss) {
        // Boss bounces horizontally
        e.x += e.vx * dt;
        if (e.x - e.width / 2 < 0) {
          e.x = e.width / 2;
          e.vx = e.vx.abs();
        } else if (e.x + e.width / 2 > _w) {
          e.x = _w - e.width / 2;
          e.vx = -e.vx.abs();
        }
      } else {
        // Random: falls straight down
        e.x += e.vx * dt;
        e.y += e.vy * dt;
      }
    }

    // Remove random enemies that fell off screen
    enemies.removeWhere(
      (e) => e.type == EnemyType.random && !e.isAlive,
    );
    enemies.removeWhere(
      (e) => e.type == EnemyType.random && e.y > _h + 40,
    );
  }

  // ── Random enemy spawning ─────────────────────────────────────────────────────

  void _spawnRandomEnemy(double dt) {
    if (_bossAlive) return; // no randoms during boss fight

    _randomSpawnTimer -= dt;
    if (_randomSpawnTimer <= 0) {
      // Increase frequency based on kills
      _randomSpawnInterval = max(1.2, 3.0 - kills * 0.05);
      _randomSpawnTimer = _randomSpawnInterval + _rng.nextDouble();

      final x = 30 + _rng.nextDouble() * (_w - 60);
      enemies.add(Enemy.random(x: x, y: -20));
    }
  }

  // ── Boss fire logic ───────────────────────────────────────────────────────────

  void _bossFireLogic(double dt) {
    for (final e in enemies) {
      if (e.type != EnemyType.boss || !e.isAlive) continue;
      e.fireTimer -= dt;
      if (e.fireTimer <= 0) {
        e.fireTimer = 1.6;
        // Fire 3-spread
        bullets.add(Bullet.enemy(x: e.x - 16, y: e.y + e.height / 2));
        bullets.add(Bullet.enemy(x: e.x,       y: e.y + e.height / 2));
        bullets.add(Bullet.enemy(x: e.x + 16,  y: e.y + e.height / 2));
      }
    }
  }

  // ── Collision detection ───────────────────────────────────────────────────────

  void _checkCollisions() {
    for (final bullet in bullets) {
      if (!bullet.isAlive) continue;

      if (!bullet.isEnemy) {
        // Player bullet vs enemies
        for (final enemy in enemies) {
          if (!enemy.isAlive) continue;
          if (bullet.rect.overlaps(enemy.rect)) {
            bullet.isAlive = false;
            enemy.health--;
            if (enemy.health <= 0) {
              enemy.isAlive = false;
              score += enemy.scoreValue;
              kills++;
              if (enemy.type == EnemyType.boss) _bossAlive = false;
              _spawnExplosion(enemy.x, enemy.y, enemy.type);
            }
            break;
          }
        }
      } else {
        // Enemy bullet vs player
        if (!player.isInvincible && bullet.rect.overlaps(player.rect)) {
          bullet.isAlive = false;
          _hitPlayer();
        }
      }
    }

    // Enemy body vs player
    if (!player.isInvincible) {
      for (final enemy in enemies) {
        if (!enemy.isAlive) continue;
        if (enemy.rect.overlaps(player.rect)) {
          enemy.isAlive = false;
          if (enemy.type == EnemyType.boss) _bossAlive = false;
          _spawnExplosion(enemy.x, enemy.y, enemy.type);
          _hitPlayer();
        }
      }
    }
  }

  void _hitPlayer() {
    player.lives--;
    player.isInvincible    = true;
    player.invincibleTimer = Player.invincibleDuration;
    _spawnExplosion(player.x, player.y, null);
    if (player.lives <= 0) {
      _triggerGameOver();
    }
  }

  void _triggerGameOver() {
    phase = GamePhase.gameOver;
  }

  // ── Explosions ────────────────────────────────────────────────────────────────

  void _spawnExplosion(double x, double y, EnemyType? type) {
    final radius = type == EnemyType.boss ? 60.0 : (type == EnemyType.wave ? 24.0 : 30.0);
    explosions.add(Explosion(x: x, y: y, maxRadius: radius));
  }

  void _updateExplosions(double dt) {
    for (final ex in explosions) ex.update(dt);
    explosions.removeWhere((ex) => ex.isDone);
  }

  // ── Wave complete ─────────────────────────────────────────────────────────────

  void _checkWaveComplete() {
    final hasWaveEnemies =
        enemies.any((e) => e.type == EnemyType.wave && e.isAlive);
    if (!hasWaveEnemies && !_bossAlive) {
      // Clear dead enemies, start next wave
      enemies.removeWhere((e) => !e.isAlive);
      wave++;
      _spawnWave();
    }
  }

  // ── Boss spawning ─────────────────────────────────────────────────────────────

  void _checkBossSpawn() {
    if (!_bossAlive && kills >= _nextBossAt) {
      _nextBossAt += 10;
      _bossAlive = true;
      enemies.add(Enemy.boss(x: _w / 2, y: 80));
    }
  }

  // ── Invincibility ─────────────────────────────────────────────────────────────

  void _updateInvincibility(double dt) {
    if (!player.isInvincible) return;
    player.invincibleTimer -= dt;
    if (player.invincibleTimer <= 0) {
      player.isInvincible    = false;
      player.invincibleTimer = 0;
    }
  }

  // ── Starfield ─────────────────────────────────────────────────────────────────

  void _scrollStars(double dt) {
    for (final s in stars) {
      s.y += s.speed * dt;
      if (s.y > _h + 2) {
        s.y = -2;
        s.x = _rng.nextDouble() * _w;
      }
    }
  }
}
