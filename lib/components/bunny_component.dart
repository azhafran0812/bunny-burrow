import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:hive/hive.dart';
import '../game/bunny_game.dart';
import '../utils/constants.dart';
import '../components/bridge_component.dart';
import '../components/burrow_door_component.dart';
import '../components/wander_zone.dart';
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
        ),
        position: Vector2(size.x / 2, size.y / 2), // Make the hitbox a bit smaller than the 128x128 sprite so it triggers closer to the center
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

    final box = Hive.box('playerData');
    final int currentBurrowLevel = box.get('burrow_level', defaultValue: 1);

    // -- BRIDGE LOGIC --
    if (other is BridgeComponent) {
      if (other.targetStageLevel <= currentBurrowLevel) {
        if (currentZone == other.zoneA) {
          currentZone = other.zoneB;
        } else if (currentZone == other.zoneB) {
          currentZone = other.zoneA;
        }
      }
    }

    // -- BURROW DOOR LOGIC --
    if (other is BurrowDoorComponent) {
      // 1. Filter to get only unlocked zones
      final unlockedZones = other.targetZones
          .where((z) => z.stageLevel <= currentBurrowLevel)
          .toList();

      // 2. Define nextZone and pick randomly if zones are unlocked
      if (unlockedZones.isNotEmpty) {
        final random = Random();
        final nextZone = unlockedZones[random.nextInt(unlockedZones.length)];

        // 3. Swap the home zone and teleport
        currentZone = nextZone;
        position = currentZone.getRandomPointInside();

        // 4. Reset movement state so the bunny doesn't get stuck
        targetPosition = null;
        current = BunnyState.idle;
        _startWanderTimer();
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