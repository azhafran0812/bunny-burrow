import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game/bunny_game.dart';
import 'burrow_door.dart';
import 'wander_zone.dart'; // <-- ADDED THIS IMPORT!

class BunnyComponent extends PositionComponent with HasGameRef<BunnyGame> {
  int currentStage;
  final Random _random = Random();

  BunnyComponent({required this.currentStage, required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2(40, 40),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Placeholder for your drawn Bunny Art!
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.white));

    // Start the AI loop 2 seconds after spawning
    Future.delayed(const Duration(seconds: 2), _decideNextAction);
  }

  // --- THE AI LOOP ---
  void _decideNextAction() {
    if (!isMounted) return; // Prevents crashes if the app closes

    // 20% chance to look for a door, 80% chance to just wander
    bool wantsToChangeRooms = _random.nextDouble() < 0.20;

    if (wantsToChangeRooms) {
      _findAndUseDoor();
    } else {
      _wanderInCurrentRoom();
    }
  }

  // --- UPDATED NORMAL HOPPING LOGIC ---
  void _wanderInCurrentRoom() {
    // 1. Find all invisible WanderZones in the current stage
    var availableZones = gameRef.world.children
        .whereType<WanderZone>()
        .where((zone) => zone.stageLevel == currentStage)
        .toList();

    if (availableZones.isEmpty) return; // Failsafe

    // 2. Pick a random zone (could be a room, could be a connecting path)
    WanderZone targetZone =
        availableZones[_random.nextInt(availableZones.length)];

    // 3. Ask the zone for a random coordinate inside its boundaries
    Vector2 targetPosition = targetZone.getRandomPointInside();

    // 4. Hop to it!
    add(
      MoveEffect.to(
        targetPosition,
        EffectController(duration: 2.0, curve: Curves.easeInOut),
        onComplete: () {
          int pauseDuration = 1 + _random.nextInt(3);
          Future.delayed(Duration(seconds: pauseDuration), _decideNextAction);
        },
      ),
    );
  }

  // --- TELEPORT LOGIC ---
  void _findAndUseDoor() {
    // Find all doors in the current stage
    var availableDoors = gameRef.world.children
        .whereType<BurrowDoor>()
        .where((door) => door.stageLevel == currentStage)
        .toList();

    // If no doors exist (or stage isn't unlocked), just wander instead
    if (availableDoors.isEmpty) {
      _wanderInCurrentRoom();
      return;
    }

    // Pick a random door
    BurrowDoor targetDoor =
        availableDoors[_random.nextInt(availableDoors.length)];

    // 1. Hop to the door
    add(
      MoveEffect.to(
        targetDoor.position,
        EffectController(duration: 2.0, curve: Curves.easeInOut),
        onComplete: () {
          // 2. Shrink down (entering the hole)
          add(
            ScaleEffect.to(
              Vector2.zero(),
              EffectController(duration: 0.5),
              onComplete: () {
                // 3. TELEPORT!
                position = targetDoor.teleportDestination;
                currentStage = targetDoor.destinationStage;

                // 4. Grow back to normal size (popping out of the new hole)
                add(
                  ScaleEffect.to(
                    Vector2.all(1.0),
                    EffectController(duration: 0.5),
                    onComplete: () {
                      // Wait a second, then resume normal wandering
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
