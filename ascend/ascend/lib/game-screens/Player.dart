import 'package:ascend/game-screens/healthbar.dart';
import 'package:ascend/game-screens/levels/level1.dart';
import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'platform.dart';
import 'constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firedemon.dart';

final supabase = Supabase.instance.client;
final user = supabase.auth.currentUser;
final userid = user?.id;

class Player extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final Platform platform;
  final String selectedCharacter; // Name of the character (e.g., warrior)
  final String selectedGender; // Gender of the character (e.g., male)
  bool isFlipped = false; // Track whether the character is flipped
  double stamina = 0;
  double strength = 0;
  double jumpStrength = 50;
  double flexibility = 0;
  double endurance = 0;
  double gravity = 800;
  bool isOnGround = false;
  double velocityY = 0; // Vertical velocity
  bool isJumping = false; // Flag to track if the player is already jumping
  bool isRunning = false; // Flag to track if the player is running
  bool isFacingRight = true; // Track the direction the player is facing
  bool isAttacking = false;
  double maxHealth = 100;
  double currentHealth = 100;

  // Animation states (nullable to handle missing data)
  SpriteAnimation? idleAnimation;
  SpriteAnimation? runRightAnimation;
  SpriteAnimation? runLeftAnimation;
  SpriteAnimation? jumpAnimation;
  SpriteAnimation? hitAnimation;
  SpriteAnimation? attackAnimation; // New attack animation
  SpriteAnimation? hurtAnimation;
  SpriteAnimation? deathAnimation;
  // Constructor accepts selected gender
  Player(this.platform, this.selectedCharacter, this.selectedGender)
      : super(size: Vector2(200, 200)); // Increased size

  Future<Map<String, dynamic>> fetchAnimationData(
      String characterName, String gender, String animationType) async {
    try {
      final response = await Supabase.instance.client
          .from('animations')
          .select('*')
          .eq('character_name', gender)
          .eq('gender', characterName)
          .eq('animation_type', animationType)
          .single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error fetching animation data: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchStatistics() async {
    try {
      // Ensure userid is not null
      if (userid == null) {
        print('User ID is null. Cannot fetch statistics.');
        return [];
      }

      // Fetch all rows from the 'statistics' table
      final response = await Supabase.instance.client
          .from('statistics')
          .select('*')
          .eq('user_id', userid!); // Use userid! to assert it's not null

      // Convert the response to a list of maps
      if (response != null) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        print('No statistics data found.');
        return [];
      }
    } catch (e) {
      print('Error fetching statistics data: $e');
      return [];
    }
  }

  @override
  Future<void> onLoad() async {
    // Load animations dynamically
    await _loadAnimations();

    // Load statistics and apply them
    await loadStats();

    // Set the initial animation to idle if available
    if (idleAnimation != null) {
      animation = idleAnimation;
    } else {
      print('Idle animation not loaded. Using default behavior.');
    }

    // Set the initial position
    position = Vector2(Constants.screenWidth * 0.8 / 2,
        platform.y - height); // Start on the platform
    add(RectangleHitbox(
      size: Vector2(width * 0.6, height * 0.8),
      position: Vector2(width * 0.2, height * 0.1),
    ));
  }

  // Load all animations dynamically
  Future<void> _loadAnimations() async {
    await _loadIdleAnimation();
    await _loadRunRightAnimation();
    // await _loadRunLeftAnimation();
    await _loadJumpAnimation();
    await _loadAttackAnimation(); // Load attack animation
    await _loadHurtAnimation();
    await _loadDeathAnimation();
  }

  Future<void> loadStats() async {
    final stats = await fetchStatistics();
    if (stats.isNotEmpty) {
      for (final stat in stats) {
        // Apply the fetched statistics to the player's properties
        stamina = stat['stamina']?.toDouble() ?? 0;
        strength = stat['strength']?.toDouble() ?? 0;
        jumpStrength = stat['jump_strength']?.toDouble() ?? 0;
        flexibility = stat['flexibility']?.toDouble() ?? 0;
        endurance = stat['endurance']?.toDouble() ?? 0;

        print('Stats loaded: '
            'Stamina: $stamina, '
            'Strength: $strength, '
            'Jump Strength: $jumpStrength, '
            'Flexibility: $flexibility, '
            'Endurance: $endurance');
      }
    } else {
      print('No statistics available.');
    }
  }

  // Load idle animation
  Future<void> _loadIdleAnimation() async {
    final animationData =
        await fetchAnimationData(selectedCharacter, selectedGender, 'idle');
    if (animationData.isEmpty) {
      print('Failed to load idle animation.');
      return;
    }
    try {
      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load(animationData['file_path']),
        srcSize: Vector2(128, 128), // Dimensions of each frame
      );
      idleAnimation = spriteSheet.createAnimation(
        row: 0, // Row index in the sprite sheet
        stepTime: 0.1, // Time per frame
        from: animationData['start_frame'], // Start frame
        to: animationData['end_frame'], // End frame
      );
    } catch (e) {
      print('Error creating idle animation: $e');
    }
  }

  Future<void> _loadHurtAnimation() async {
    final animationData =
        await fetchAnimationData(selectedCharacter, selectedGender, 'hurt');
    if (animationData.isEmpty) {
      print('Failed to load hurt animation.');
      return;
    }
    try {
      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load(animationData['file_path']),
        srcSize: Vector2(128, 128), // Dimensions of each frame
      );
      hurtAnimation = spriteSheet.createAnimation(
        row: 0, // Row index in the sprite sheet
        stepTime: 0.1, // Time per frame
        from: animationData['start_frame'], // Start frame
        to: animationData['end_frame'], // End frame
      );
      print("Hurt animation loaded successfully.");
      print('animationData: $animationData');
    } catch (e) {
      print('Error creating hurt animation: $e');
    }
  }

  Future<void> _loadDeathAnimation() async {
    final animationData =
        await fetchAnimationData(selectedCharacter, selectedGender, 'dead');
    if (animationData.isEmpty) {
      print('Failed to load death animation.');
      return;
    }
    try {
      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load(animationData['file_path']),
        srcSize: Vector2(128, 128), // Dimensions of each frame
      );
      deathAnimation = spriteSheet.createAnimation(
        row: 0, // Row index in the sprite sheet
        stepTime: 0.1, // Time per frame
        from: animationData['start_frame'], // Start frame
        to: animationData['end_frame'], // End frame
      );
    } catch (e) {
      print('Error creating idle animation: $e');
    }
  }

  // Load run right animation
  Future<void> _loadRunRightAnimation() async {
    final animationData = await fetchAnimationData(
        selectedCharacter, selectedGender, 'run_right');
    if (animationData.isEmpty) {
      print('Failed to load run_right animation.');
      return;
    }
    try {
      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load(animationData['file_path']),
        srcSize: Vector2(128, 128), // Dimensions of each frame
      );
      runRightAnimation = spriteSheet.createAnimation(
        row: 0, // Row index in the sprite sheet
        stepTime: 0.1, // Time per frame
        from: animationData['start_frame'], // Start frame
        to: animationData['end_frame'], // End frame
      );
    } catch (e) {
      print('Error creating run_right animation: $e');
    }
  }

  // // Load run left animation
  // Future<void> _loadRunLeftAnimation() async {
  //   final animationData =
  //       await fetchAnimationData(selectedCharacter, selectedGender, 'run_left');
  //   if (animationData.isEmpty) {
  //     print('Failed to load run_left animation.');
  //     return;
  //   }
  //   try {
  //     final spriteSheet = SpriteSheet(
  //       image: await gameRef.images.load(animationData['file_path']),
  //       srcSize: Vector2(128, 128), // Dimensions of each frame
  //     );
  //     runLeftAnimation = spriteSheet.createAnimation(
  //       row: 0, // Row index in the sprite sheet
  //       stepTime: 0.1, // Time per frame
  //       from: animationData['start_frame'], // Start frame
  //       to: animationData['end_frame'], // End frame
  //     );
  //   } catch (e) {
  //     print('Error creating run_left animation: $e');
  //   }
  // }

  // Load jump animation
  Future<void> _loadJumpAnimation() async {
    final animationData =
        await fetchAnimationData(selectedCharacter, selectedGender, 'jump');
    if (animationData.isEmpty) {
      print('Failed to load jump animation.');
      return;
    }
    try {
      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load(animationData['file_path']),
        srcSize: Vector2(128, 128), // Dimensions of each frame
      );
      jumpAnimation = spriteSheet.createAnimation(
        row: 0, // Row index in the sprite sheet
        stepTime: 0.1, // Time per frame
        from: animationData['start_frame'], // Start frame
        to: animationData['end_frame'], // End frame
      );
    } catch (e) {
      print('Error creating jump animation: $e');
    }
  }

  // Load attack animation
  Future<void> _loadAttackAnimation() async {
    final animationData =
        await fetchAnimationData(selectedCharacter, selectedGender, 'attack');
    if (animationData.isEmpty) {
      print('Failed to load attack animation.');
      return;
    }
    try {
      print('Loading attack animation...');
      print('File path: ${animationData['file_path']}');
      print('Start frame: ${animationData['start_frame']}');
      print('End frame: ${animationData['end_frame']}');

      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load(animationData['file_path']),
        srcSize: Vector2(128, 128),
      );
      attackAnimation = spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        from: animationData['start_frame'],
        to: animationData['end_frame'],
      );
      print('Attack animation loaded successfully.');
    } catch (e) {
      print('Error creating attack animation: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isHurt && hurtAnimation != null) {
      animation = hurtAnimation;
      return; // Don't process other animations while hurt
    }

    // Apply gravity
    velocityY += gravity * dt;

    // Update vertical position based on velocity
    position.y += velocityY * dt;

    // Handle animations
    if (isAttacking && attackAnimation != null) {
      // Prioritize attack animation above all others
      animation = attackAnimation;
      if (!isFacingRight && !isFlipped) {
        // Flip the attack animation if facing left and not already flipped
        flipHorizontallyAroundCenter();
        isFlipped = true;
      } else if (isFacingRight && isFlipped) {
        // Unflip the attack animation if facing right and currently flipped
        flipHorizontallyAroundCenter();
        isFlipped = false;
      }
    } else if (!isOnGround && jumpAnimation != null) {
      // Play jump animation if in the air
      animation = jumpAnimation;
      if (!isFacingRight && !isFlipped) {
        // Flip the jump animation if facing left and not already flipped
        flipHorizontallyAroundCenter();
        isFlipped = true;
      } else if (isFacingRight && isFlipped) {
        // Unflip the jump animation if facing right and currently flipped
        flipHorizontallyAroundCenter();
        isFlipped = false;
      }
    } else if (isRunning) {
      // Handle running animations
      if (runRightAnimation != null) {
        animation = runRightAnimation;
        if (!isFacingRight && !isFlipped) {
          // Flip the running animation if facing left and not already flipped
          flipHorizontallyAroundCenter();
          isFlipped = true;
        } else if (isFacingRight && isFlipped) {
          // Unflip the running animation if facing right and currently flipped
          flipHorizontallyAroundCenter();
          isFlipped = false;
        }
      }
    } else if (idleAnimation != null) {
      // Default to idle animation
      animation = idleAnimation;
      if (isFlipped) {
        // Unflip the character if currently flipped
        flipHorizontallyAroundCenter();
        isFlipped = false;
      }
    }
    if (isAttacking) checkAttackCollisions();

    // Check if the player is on the platform
    if (position.y + height >= platform.y &&
        position.x + width > platform.x &&
        position.x < platform.x + platform.width) {
      position.y = platform.y - height; // Snap to the platform
      velocityY = 0; // Stop falling
      isOnGround = true;
      isJumping = false; // Allow jumping again
    } else {
      isOnGround = false;
    }

    // Endless loop logic
    if (position.x > Constants.screenWidth) {
      // Player has moved past the right boundary
      position.x = 0 - width; // Teleport to the left side
    } else if (position.x + width < 0) {
      // Player has moved past the left boundary
      position.x = Constants.screenWidth; // Teleport to the right side
    }
  }

  bool isHurt = false;

  void hurt() {
    if (isDead || isHurt || hurtAnimation == null) return;

    currentHealth -= 10;
    currentHealth = currentHealth.clamp(0, maxHealth);
    print('Player health: $currentHealth');

    if (currentHealth <= 0) {
      die(); // Trigger death instead of hurt animation
      return;
    }

    // Only play hurt animation if not dead
    isHurt = true;
    animation = hurtAnimation;

    Future.delayed(Duration(milliseconds: 500), () {
      isHurt = false;
      if (!isDead && idleAnimation != null) {
        animation = idleAnimation;
      }
    });
  }

  bool isDead = false;

  void die() {
    if (isDead || deathAnimation == null) return;

    print('🔥 Player is dying');
    isDead = true;

    // Stop all other animations and behaviors
    isRunning = false;
    isAttacking = false;
    isHurt = false;

    // Set the death animation
    animation = deathAnimation;

    // Use the animation's onComplete callback
    animationTicker?.onComplete = () {
      _completeDeath();
    };

    // Fallback in case animationTicker doesn't fire
    final deathDuration = deathAnimation!.frames.length * 0.1;
    Future.delayed(Duration(milliseconds: (deathDuration * 1000).toInt()), () {
      if (!isDead) return; // Already handled
      _completeDeath();
    });
  }

  void _completeDeath() {
    print('☠️ Death animation complete');
    if (gameRef.buildContext == null || !gameRef.buildContext!.mounted) return;

    // Pause the game before navigating
    gameRef.pauseEngine();

    // Navigate back to home
    Navigator.of(gameRef.buildContext!).pop();
  }

  // Add this to your Player class
  void checkAttackCollisions() {
    if (!isAttacking) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastAttackTime != null && now - lastAttackTime! < 500) {
      return; // Only allow one attack every 500ms
    }
    lastAttackTime = now;

    final potentialTargets = parent?.children.whereType<FireDemon>() ?? [];
    print("Checking attack against ${potentialTargets.length} demons");

    for (final demon in potentialTargets) {
      if (_isInAttackRange(demon)) {
        print("Attacking demon at ${demon.position}");
        demon.takeDamage(10); // Fixed damage value for testing
      }
    }
  }

// Add this class variable
  int? lastAttackTime;

  bool _isInAttackRange(FireDemon demon) {
    final distance = (position - demon.position).length;
    final isFacingDemon = (isFacingRight && demon.position.x > position.x) ||
        (!isFacingRight && demon.position.x < position.x);

    final inRange = distance < 150;
    print("""
  Attack range check:
  Distance: $distance
  Facing: $isFacingDemon
  In range: $inRange
  """);

    return isFacingDemon && inRange;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is FireBall) {
      hurt(); // Call yorur animation trigger
      print("Player hit by fireball!");
    }
  }

  void attack() {
    if (attackAnimation == null) {
      print('Attack animation not loaded.');
      return;
    }

    if (!isAttacking) {
      isAttacking = true;
      animation = attackAnimation;

      // Check for collisions at the peak of the attack
      Future.delayed(Duration(milliseconds: 200), () {
        if (isAttacking) {
          checkAttackCollisions();
        }
      });

      animationTicker?.onComplete = () {
        isAttacking = false;
        animationTicker?.onComplete = null;
        if (!isFacingRight && isFlipped) {
          flipHorizontallyAroundCenter();
          isFlipped = false;
        }
        if (idleAnimation != null) {
          animation = idleAnimation;
        }
      };

      final attackDuration = attackAnimation!.frames.length * 0.1;
      Future.delayed(Duration(milliseconds: (attackDuration * 1000).toInt()),
          () {
        if (isAttacking) {
          isAttacking = false;
          if (!isFacingRight && isFlipped) {
            flipHorizontallyAroundCenter();
            isFlipped = false;
          }
          if (idleAnimation != null) {
            animation = idleAnimation;
          }
        }
      });
    }
  }

  void jump() {
    if (isOnGround && !isJumping) {
      // Apply upward velocity to simulate a jump
      velocityY = -jumpStrength * 2; // Use jumpStrength from statistics
      isJumping = true;

      // Reset flip state if facing left
      if (!isFacingRight && isFlipped) {
        flipHorizontallyAroundCenter();
        isFlipped = false;
      }
    }
  }

  void move(Vector2 delta) {
    if (delta.x != 0) {
      final movementSpeed =
          stamina * 0.1; // Use stamina from statistics to determine speed
      // Player is moving horizontally
      isRunning = true;

      // Determine the direction the player is facing
      if (delta.x > 0) {
        // Moving right
        isFacingRight = true;
      } else if (delta.x < 0) {
        // Moving left
        isFacingRight = false;
      }

      // Update the player's position based on joystick input
      position.x += delta.x * movementSpeed;
    } else {
      // Joystick is not being touched (no horizontal movement)
      isRunning = false;
    }
  }
}
