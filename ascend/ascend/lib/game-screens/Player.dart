import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'platform.dart';
import 'constants.dart';

class Player extends SpriteComponent with HasGameRef<LobbyWorld> {
  final Platform platform;
  final String selectedGender; // Add this field
  double speed = 200; // Movement speed
  double gravity = 800; // Gravity strength
  bool isOnGround = false;
  double velocityY = 0; // Vertical velocity
  bool isJumping = false; // Flag to track if the player is already jumping

  // Constructor accepts selected gender
  Player(this.platform, this.selectedGender)
      : super(size: Vector2(100, 100)); // Increased size

  @override
  Future<void> onLoad() async {
    // Dynamically load the sprite based on the selected gender
    sprite = await Sprite.load(
        'game_images/$selectedGender/${selectedGender}_idle.png');
    position = Vector2(Constants.screenWidth * 0.8/2,
        platform.y - height); // Start on the platform
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity
    velocityY += gravity * dt;

    // Update vertical position based on velocity
    position.y += velocityY * dt;

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

  // Jump method
  void jump() {
    if (isOnGround && !isJumping) {
      // Apply upward velocity to simulate a jump
      velocityY = -300; // Adjust this value based on your game's physics
      isJumping = true;
      print('Player jumped!');
    }
  }

  // Method to handle movement from the joystick
  void move(Vector2 delta) {
    position.x += delta.x * speed;
  }
}