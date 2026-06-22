import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BurrowDoor extends PositionComponent {
  final int stageLevel; // The room this door is physically in
  final Vector2 teleportDestination; // Where the bunny pops out
  final int destinationStage; // The room the bunny arrives in

  BurrowDoor({
    required this.stageLevel,
    required this.teleportDestination,
    required this.destinationStage,
    required Vector2 position,
  }) : super(position: position, size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Placeholder for your actual Door/Hole art!
    // For now, it's a black circle representing a hole in the dirt.
    add(
      CircleComponent(
        radius: 25,
        paint: Paint()..color = Colors.black87,
        anchor: Anchor.topLeft,
      ),
    );
  }
}
