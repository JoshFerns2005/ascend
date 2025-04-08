import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ascend/game-screens/levels/level1.dart';
import 'Player.dart';

enum FireDemonState { idle, attack, flying, hurt, death }

class FireDemon extends SpriteAnimationGroupComponent<FireDemonState>
    with HasGameRef, CollisionCallbacks {
  final Player player;
  final Level1 world;
  final BuildContext context; // <--- Added context
  late Timer attackTimer;
  late Vector2 spawnPosition;
  double maxHealth = 100;
  double currentHealth = 100;
  late TextComponent healthText;
  bool isDead = false;
  late RectangleHitbox hitbox;

  FireDemon(this.player, this.spawnPosition, this.world, this.context)
      : super(size: Vector2(169, 169));

  FireDemonState? _previousState;

  @override
  set current(FireDemonState? newState) {
    if (newState != _previousState && newState != null) {
      _previousState = newState;
    }
    super.current = newState;
  }

  @override
  Future<void> onLoad() async {
    position = spawnPosition;

    final frameSize = Vector2(80.5, 80.5);

    healthText = TextComponent(
      text: '${currentHealth.toInt()}/$maxHealth',
      position: Vector2(width * 0.5, -30),
      anchor: Anchor.topCenter,
      priority: 100,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))
          ],
        ),
      ),
    );
    add(healthText);

    // Load animations
    final idleSheet = SpriteSheet(
      image: await gameRef.images.load('game_images/Enemy/FireDemon/IDLE.png'),
      srcSize: frameSize,
    );
    final attackSheet = SpriteSheet(
      image:
          await gameRef.images.load('game_images/Enemy/FireDemon/ATTACK.png'),
      srcSize: frameSize,
    );
    final flyingSheet = SpriteSheet(
      image:
          await gameRef.images.load('game_images/Enemy/FireDemon/FLYING.png'),
      srcSize: frameSize,
    );
    final hurtSheet = SpriteSheet(
      image: await gameRef.images.load('game_images/Enemy/FireDemon/HURT.png'),
      srcSize: frameSize,
    );
    final deathSheet = SpriteSheet(
      image: await gameRef.images.load('game_images/Enemy/FireDemon/DEATH.png'),
      srcSize: frameSize,
    );

    animations = {
      FireDemonState.idle: idleSheet.createAnimation(
          row: 0, stepTime: 0.2, from: 0, to: 4, loop: true),
      FireDemonState.attack:
          attackSheet.createAnimation(row: 0, stepTime: 0.15, from: 0, to: 8),
      FireDemonState.flying:
          flyingSheet.createAnimation(row: 0, stepTime: 0.15, from: 0, to: 4),
      FireDemonState.hurt:
          hurtSheet.createAnimation(row: 0, stepTime: 0.2, from: 0, to: 4),
      FireDemonState.death:
          deathSheet.createAnimation(row: 0, stepTime: 0.2, from: 0, to: 7),
    };

    current = FireDemonState.idle;
    hitbox = RectangleHitbox(
      size: Vector2(120, 140),
      position: Vector2(25, 15),
    )..collisionType = CollisionType.active;

    add(hitbox);
    attackTimer = Timer(5, repeat: true, onTick: _attackPlayer)..start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    attackTimer.update(dt);
    healthText.position = Vector2(width * 0.5, -30);
  }

  void takeDamage(double damage) {
    if (isDead) return;

    currentHealth -= damage;
    currentHealth = currentHealth.clamp(0, maxHealth);
    healthText.text = '${currentHealth.toInt()}/$maxHealth';

    if (currentHealth <= 0) {
      die();
    } else {
      current = FireDemonState.hurt;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isDead) {
          current = FireDemonState.idle;
        }
      });
    }
  }

  void die() {
    if (isDead) return;

    isDead = true;
    current = FireDemonState.death;
    attackTimer.stop();

    if (hitbox != null) {
      remove(hitbox);
    }

    animationTicker?.onComplete = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog();
      });
    };

    Future.delayed(const Duration(seconds: 3), () {
      if (!isRemoved && !gameRef.paused) {
        _showVictoryDialog();
      }
    });
  }

  void _showVictoryDialog() {
    if (context.mounted) {
      gameRef.pauseEngine();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("You Win!"),
          content: const Text(
            "Level 1 completed!\n\nMore levels coming soon!",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); 
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _completeDeath() {
    print('☠️ Death animation complete');
    if (gameRef.buildContext == null || !gameRef.buildContext!.mounted) return;

    // Pause the game
    gameRef.pauseEngine();

    //back to home
    Navigator.of(gameRef.buildContext!).pop();
  }

  void _attackPlayer() {
    if (isDead) return;

    current = FireDemonState.attack;
    final mouthOffset = Vector2(size.x * 0.6, size.y * 0.4);
    final spawnPoint = position + mouthOffset;
    world.add(FireBall(spawnPoint));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!isDead) current = FireDemonState.idle;
    });
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is RectangleHitbox &&
        other.collisionType == CollisionType.passive &&
        other.parent is Player) {
      final player = other.parent as Player;
      if (player.isAttacking) {
        takeDamage(player.strength);
      }
    }

    if (other is FireBall) {}
  }
}

class FireBall extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  FireBall(Vector2 spawnPosition)
      : super(
          position: spawnPosition,
          size: Vector2(48, 32),
          anchor: Anchor.center,
          priority: 100,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final spriteSheet = SpriteSheet(
      image: await gameRef.images
          .load('game_images/Enemy/FireDemon/projectile.png'),
      srcSize: Vector2(32, 32),
    );
    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.1,
      from: 0,
      to: 1,
      loop: true,
    );
    add(CircleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(-100, 0) * dt;

    if (position.x < -100) {
      removeFromParent();
    }
  }
}
