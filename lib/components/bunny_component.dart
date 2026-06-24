import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game/bunny_game.dart';
import 'burrow_door.dart';
import 'wander_zone.dart';


// 1. Define the possible states for our animation group
enum BunnyState { idle, hopping }

// 2. Change the extension to SpriteAnimationGroupComponent
class BunnyComponent extends SpriteAnimationGroupComponent<BunnyState>
    with HasGameRef<BunnyGame> {
  int currentStage;
  final Random _random = Random();

  // Keep track of the bunny's direction so we can flip the sprite!
  bool isFacingRight = true;

  BunnyComponent({required this.currentStage, required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2(
          128,
          128,
        ), // Physical hitbox stays 40x40, the 128x128 art scales to fit!
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 3. Load and slice the Idle Sprite Sheet
    final idleAnimation = await gameRef.loadSpriteAnimation(
      'bunny_idle.png',
      SpriteAnimationData.sequenced(
        amount: 5, // 640px / 128px = 5 frames
        stepTime: 0.2, // Speed of the idle breathing/twitching
        textureSize: Vector2(128, 128),
      ),
    );

    // 4. Load and slice the Hop Sprite Sheet
    final hopAnimation = await gameRef.loadSpriteAnimation(
      'bunny_hop.png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1, // Faster frame rate for moving
        textureSize: Vector2(128, 128),
      ),
    );

    // 5. Register the animations to our states
    animations = {
      BunnyState.idle: idleAnimation,
      BunnyState.hopping: hopAnimation,
    };

    // Set the starting animation
    current = BunnyState.idle;

    // Start the AI loop 2 seconds after spawning
    Future.delayed(const Duration(seconds: 2), _decideNextAction);
  }

  // --- DIRECTION HELPER ---
  void _faceTarget(Vector2 target) {
    // If target is to our left, but we are facing right -> FLIP LEFT
    if (target.x < position.x && isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
    }
    // If target is to our right, but we are facing left -> FLIP RIGHT
    else if (target.x > position.x && !isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
    }
  }

  // --- THE AI LOOP ---
  void _decideNextAction() {
    if (!isMounted) return;

    bool wantsToChangeRooms = _random.nextDouble() < 0.20;

    if (wantsToChangeRooms) {
      _findAndUseDoor();
    } else {
      _wanderInCurrentRoom();
    }
  }

  // --- NORMAL HOPPING LOGIC ---
  void _wanderInCurrentRoom() {
    var availableZones = gameRef.world.children
        .whereType<WanderZone>()
        .where((zone) => zone.stageLevel == currentStage)
        .toList();

    if (availableZones.isEmpty) return;

    WanderZone targetZone =
        availableZones[_random.nextInt(availableZones.length)];
    Vector2 targetPosition = targetZone.getRandomPointInside();

    // 1. Turn around if needed, and change the animation to hopping!
    _faceTarget(targetPosition);
    current = BunnyState.hopping;

    // 2. Hop to the target!
    add(
      MoveEffect.to(
        targetPosition,
        EffectController(duration: 2.0, curve: Curves.easeInOut),
        onComplete: () {
          // 3. We arrived! Change animation back to idle
          current = BunnyState.idle;

          int pauseDuration = 1 + _random.nextInt(3);
          Future.delayed(Duration(seconds: pauseDuration), _decideNextAction);
        },
      ),
    );
  }

  // --- TELEPORT LOGIC ---
  void _findAndUseDoor() {
    var availableDoors = gameRef.world.children
        .whereType<BurrowDoor>()
        .where((door) => door.stageLevel == currentStage)
        .toList();

    if (availableDoors.isEmpty) {
      _wanderInCurrentRoom();
      return;
    }

    BurrowDoor targetDoor =
        availableDoors[_random.nextInt(availableDoors.length)];

    // Turn to face the door and start hopping!
    _faceTarget(targetDoor.position);
    current = BunnyState.hopping;

    add(
      MoveEffect.to(
        targetDoor.position,
        EffectController(duration: 2.0, curve: Curves.easeInOut),
        onComplete: () {
          // We reached the door, shrink down into the hole!
          add(
            ScaleEffect.to(
              Vector2.zero(),
              EffectController(duration: 0.5),
              onComplete: () {
                // TELEPORT!
                position = targetDoor.teleportDestination;
                currentStage = targetDoor.destinationStage;

                // Pop out of the new hole!
                // We use isFacingRight to ensure we don't accidentally un-flip the sprite while growing
                add(
                  ScaleEffect.to(
                    Vector2(isFacingRight ? 1.0 : -1.0, 1.0),
                    EffectController(duration: 0.5),
                    onComplete: () {
                      // Change back to idle and wait a second before moving again
                      current = BunnyState.idle;
                      Future.delayed(
                        const Duration(seconds: 1),
                        _decideNextAction,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
