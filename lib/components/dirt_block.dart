import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class DirtBlock extends PositionComponent {
  final int stage; // Tracks if this block belongs to Stage 2 or Stage 3

  DirtBlock({
    required this.stage,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // A dark, packed-dirt placeholder color
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF4A3728)
          ..style = PaintingStyle.fill,
      ),
    );
  }

  // We call this when the player buys the expansion
  void crumble() {
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.5, curve: Curves.easeIn),
        onComplete: removeFromParent, // Deletes it from memory when finished
      ),
    );
  }
}
