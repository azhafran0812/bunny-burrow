import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import '../game/bunny_game.dart';
import '../utils/constants.dart';
import '../components/bridge_component.dart';
import 'burrow_door.dart';
import 'wander_zone.dart';


enum BunnyState { idle, hopping }

class BunnyComponent extends SpriteAnimationGroupComponent<BunnyState>
    with HasGameRef<BunnyGame>, CollisionCallbacks {
  final BunnyBreed breed;
  WanderZone currentZone;

  Vector2? targetPosition;
  late final double
  speed; // Make this 'late' so we can assign it in the constructor

  BunnyComponent({required this.breed, required this.currentZone})
    : super(size: Vector2(128, 128), anchor: Anchor.center) {
    // Assign the custom speed for this specific breed
    speed = breed.speed;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Dynamically grab the frame counts from the enum extension
    final idleSprite = await gameRef.loadSpriteAnimation(
      '${breed.name}_idle.png',
      SpriteAnimationData.sequenced(
        amount: breed.idleFrameCount, // <-- Dynamic!
        stepTime: 0.2,
        textureSize: Vector2(
          128,
          128,
        ), // Update this too if breeds have different sized PNGs
      ),
    );

    final hoppingSprite = await gameRef.loadSpriteAnimation(
      '${breed.name}_hopping.png',
      SpriteAnimationData.sequenced(
        amount: breed.hoppingFrameCount, // <-- Dynamic!
        stepTime: 0.15,
        textureSize: Vector2(128, 128),
      ),
    );

    animations = {
      BunnyState.idle: idleSprite,
      BunnyState.hopping: hoppingSprite,
    };

    add(
      RectangleHitbox(
        size: Vector2(
          32,
          32,
        ), // Make the hitbox a bit smaller than the 128x128 sprite so it triggers closer to the center
        anchor: Anchor.center,
      ),
    );

    current = BunnyState.idle;
    position = currentZone.getRandomPointInside();
    _startWanderTimer();
  }

  void _startWanderTimer() {
    // Wait a few seconds, then pick a new spot
    Future.delayed(Duration(seconds: Random().nextInt(3) + 2), () {
      if (isMounted) chooseNewDestination();
    });
  }

  void chooseNewDestination() {
    // THE SECRET SAUCE:
    // By ONLY asking the currentZone for a random point, the bunny can NEVER 
    // teleport to a disconnected zone or a locked stage!
    targetPosition = currentZone.getRandomPointInside();
    
    // Flip sprite based on direction (assuming original faces right)
    if (targetPosition!.x < position.x && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (targetPosition!.x > position.x && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    current = BunnyState.hopping;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Check if the thing we just bumped into is a bridge
    if (other is BridgeComponent) {
      // If we are currently in Zone A, swap our home to Zone B!
      if (currentZone == other.zoneA) {
        currentZone = other.zoneB;
        print("Bunny crossed into Zone B!");
      }
      // If we are currently in Zone B, swap our home to Zone A!
      else if (currentZone == other.zoneB) {
        currentZone = other.zoneA;
        print("Bunny crossed back into Zone A!");
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (targetPosition != null && current == BunnyState.hopping) {
      // Move towards the target
      final direction = (targetPosition! - position).normalized();
      position += direction * speed * dt;

      // Check if we arrived
      if (position.distanceTo(targetPosition!) < 2.0) {
        position = targetPosition!;
        targetPosition = null;
        current = BunnyState.idle;
        _startWanderTimer(); // Start waiting again
      }
    }
  }
}