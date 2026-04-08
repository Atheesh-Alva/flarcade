import 'dart:ui';

// ── Star (parallax background) ────────────────────────────────────────────────

class Star {
  double x, y, speed, radius, opacity;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

// ── Player ────────────────────────────────────────────────────────────────────

class Player {
  double x, y;
  int lives;
  double fireTimer;
  bool isInvincible;
  double invincibleTimer;

  static const double width            = 40;
  static const double height           = 40;
  static const double speed            = 220; // px/s
  static const double fireInterval     = 0.28; // seconds
  static const double invincibleDuration = 2.0; // seconds

  Player({required this.x, required this.y})
      : lives = 3,
        fireTimer = 0,
        isInvincible = false,
        invincibleTimer = 0;

  Rect get rect =>
      Rect.fromCenter(center: Offset(x, y), width: width, height: height);
}

// ── Bullet ────────────────────────────────────────────────────────────────────

class Bullet {
  double x, y, vy;
  final bool isEnemy;
  bool isAlive;

  static const double width       = 4;
  static const double playerH     = 14;
  static const double enemyH      = 10;
  static const double playerSpeed = -440; // upward
  static const double enemySpeed  = 280;  // downward

  Bullet.player({required this.x, required this.y})
      : vy = playerSpeed,
        isEnemy = false,
        isAlive = true;

  Bullet.enemy({required this.x, required this.y})
      : vy = enemySpeed,
        isEnemy = true,
        isAlive = true;

  double get height => isEnemy ? enemyH : playerH;

  Rect get rect =>
      Rect.fromCenter(center: Offset(x, y), width: width, height: height);
}

// ── Enemy ─────────────────────────────────────────────────────────────────────

enum EnemyType { wave, random, boss }

class Enemy {
  double x, y, vx, vy;
  int health, maxHealth;
  final EnemyType type;
  bool isAlive;
  double fireTimer;

  // Wave enemy
  Enemy.wave({required this.x, required this.y, required this.vx})
      : vy = 0,
        health = 1,
        maxHealth = 1,
        type = EnemyType.wave,
        isAlive = true,
        fireTimer = 0;

  // Random falling enemy
  Enemy.random({required this.x, required this.y, this.vx = 0})
      : vy = 90,
        health = 2,
        maxHealth = 2,
        type = EnemyType.random,
        isAlive = true,
        fireTimer = 0;

  // Boss
  Enemy.boss({required this.x, required this.y})
      : vx = 70,
        vy = 0,
        health = 20,
        maxHealth = 20,
        type = EnemyType.boss,
        isAlive = true,
        fireTimer = 0;

  double get width {
    switch (type) {
      case EnemyType.boss:   return 80;
      case EnemyType.wave:   return 32;
      case EnemyType.random: return 28;
    }
  }

  double get height {
    switch (type) {
      case EnemyType.boss:   return 50;
      case EnemyType.wave:   return 24;
      case EnemyType.random: return 28;
    }
  }

  int get scoreValue {
    switch (type) {
      case EnemyType.boss:   return 200;
      case EnemyType.random: return 20;
      case EnemyType.wave:   return 10;
    }
  }

  Rect get rect =>
      Rect.fromCenter(center: Offset(x, y), width: width, height: height);
}

// ── Explosion ─────────────────────────────────────────────────────────────────

class Explosion {
  final double x, y, maxRadius;
  double progress; // 0 → 1
  bool isDone;

  Explosion({required this.x, required this.y, required this.maxRadius})
      : progress = 0,
        isDone = false;

  void update(double dt) {
    progress += dt * 2.8;
    if (progress >= 1.0) {
      progress = 1.0;
      isDone = true;
    }
  }

  double get currentRadius => maxRadius * progress;
  double get opacity => (1 - progress).clamp(0.0, 1.0);
}
