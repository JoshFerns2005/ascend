import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'platform.dart';
import 'constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class Player extends SpriteAnimationComponent with HasGameRef<LobbyWorld> {
  final Platform platform;
  final String selectedCharacter; // Name of the character (e.g., warrior)
  final String selectedGender; // Gender of the character (e.g., male)
  double speed = 5; // Movement speed
  double gravity = 800; // Gravity strength
  bool isOnGround = false;
  double velocityY = 0; // Vertical velocity
  bool isJumping = false; // Flag to track if the player is already jumping
  bool isRunning = false; // Flag to track if the player is running
  bool isFacingRight = true; // Track the direction the player is facing
  bool isAttacking = false;
  // Animation states (nullable to handle missing data)
  SpriteAnimation? idleAnimation;
  SpriteAnimation? runRightAnimation;
  SpriteAnimation? runLeftAnimation;
  SpriteAnimation? jumpAnimation;
  SpriteAnimation? hitAnimation;
  SpriteAnimation? attackAnimation; // New attack animation

  // Constructor accepts selected gender
  Player(this.platform, this.selectedCharacter, this.selectedGender)
      : super(size: Vector2(200, 200)); // Increased size

  @override
  Future<void> onLoad() async {
    // Load animations dynamically
    await _loadAnimations();

    // Set the initial animation to idle if available
    if (idleAnimation != null) {
      animation = idleAnimation;
    } else {
      print('Idle animation not loaded. Using default behavior.');
    }

    // Set the initial position
    position = Vector2(Constants.screenWidth * 0.8 / 2,
        platform.y - height); // Start on the platform
  }

  // Load all animations dynamically
  Future<void> _loadAnimations() async {
    await _loadIdleAnimation();
    await _loadRunRightAnimation();
    await _loadRunLeftAnimation();
    await _loadJumpAnimation();
    await _loadAttackAnimation(); // Load attack animation
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

  // Load run left animation
  Future<void> _loadRunLeftAnimation() async {
    final animationData =
        await fetchAnimationData(selectedCharacter, selectedGender, 'run_left');
    if (animationData.isEmpty) {
      print('Failed to load run_left animation.');
      return;
    }
    try {
      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load(animationData['file_path']),
        srcSize: Vector2(128, 128), // Dimensions of each frame
      );
      runLeftAnimation = spriteSheet.createAnimation(
        row: 0, // Row index in the sprite sheet
        stepTime: 0.1, // Time per frame
        from: animationData['start_frame'], // Start frame
        to: animationData['end_frame'], // End frame
      );
    } catch (e) {
      print('Error creating run_left animation: $e');
    }
  }

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

    // Apply gravity
    velocityY += gravity * dt;

    // Update vertical position based on velocity
    position.y += velocityY * dt;

   
    // Handle animations
    if (isAttacking && attackAnimation != null) {
      // Prioritize attack animation
      animation = attackAnimation;
    } else if (!isOnGround && jumpAnimation != null) {
      // Play jump animation if in the air
      animation = jumpAnimation;
    } else if (isOnGround) {
      // Handle movement animations (idle/run)
      if (isRunning) {
        if (isFacingRight && runRightAnimation != null) {
          animation = runRightAnimation;
        } else if (!isFacingRight && runLeftAnimation != null) {
          animation = runLeftAnimation;
        }
      } else if (idleAnimation != null) {
        animation = idleAnimation;
      }
    }
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


    // Prevent the player from going out of bounds horizontally
    if (position.x < 0) {
      position.x = 0;
    } else if (position.x + width > Constants.screenWidth) {
      position.x = Constants.screenWidth - width;
    }
  }

  void attack() {
    if (attackAnimation == null) {
      print('Attack animation not loaded.');
      return;
    }

    if (!isAttacking) {
      isAttacking = true; // Set attack state
      animation = attackAnimation; // Set the attack animation

      // Debugging: Verify the animation is set
      print('Attack animation set: ${animation?.frames.length} frames');

      // Use the onComplete callback of the SpriteAnimationTicker
      animationTicker?.onComplete = () {
        print('Attack animation completed.'); // Debugging
        isAttacking = false; // Reset attack state
        animationTicker?.onComplete = null; // Clear the callback

        // Switch back to idle animation if on the ground
        if (isOnGround && idleAnimation != null) {
          animation = idleAnimation;
        }
      };

      // Fallback: Manually reset isAttacking after the attack animation duration
      final attackDuration =
          attackAnimation!.frames.length * 0.1; // Calculate duration
      Future.delayed(Duration(milliseconds: (attackDuration * 1000).toInt()),
          () {
        if (isAttacking) {
          print('Fallback: Resetting isAttacking.'); // Debugging
          isAttacking = false;

          // Switch back to idle animation if on the ground
          if (isOnGround && idleAnimation != null) {
            animation = idleAnimation;
          }
        }
      });

      print('Player is attacking!');
    }
  }

  // Jump method
  void jump() {
    if (isOnGround && !isJumping && !isAttacking) {
      // Apply upward velocity to simulate a jump
      velocityY = -300; // Adjust this value based on your game's physics
      isJumping = true;
      print('Player jumped!');
    }
  }

  // Move method
  void move(Vector2 delta) {
    if (delta.x != 0 && !isAttacking) {
      // Player is moving horizontally
      isRunning = true;

      // Determine the direction the player is facing
      if (delta.x > 0) {
        // Moving right
        isFacingRight = true;
        if (runRightAnimation != null && animation != runRightAnimation) {
          animation = runRightAnimation;
        }
      } else if (delta.x < 0) {
        // Moving left
        isFacingRight = false;
        if (runLeftAnimation != null && animation != runLeftAnimation) {
          animation = runLeftAnimation;
        }
      }

      // Update the player's position based on joystick input
      position.x += delta.x * speed;
    } else {
      // Joystick is not being touched (no horizontal movement)
      isRunning = false;

      // Switch back to idle animation when not moving and on the ground
      if (isOnGround && idleAnimation != null && animation != idleAnimation) {
        animation = idleAnimation;
      }
    }
  }
}
