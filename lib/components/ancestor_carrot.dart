import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game/bunny_game.dart';
import 'floating_text.dart';

// Extends SpriteComponent to render your custom 701x928 png illustration
class AncestorCarrot extends SpriteComponent
    with TapCallbacks, HasGameRef<BunnyGame> {
  AncestorCarrot()
    : super(
        size: Vector2(701, 928), // Your exact illustration dimensions
        anchor: Anchor
            .center, // Center anchor keeps the squish animation looking natural
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Dynamically load your illustration from the assets/images/ folder
    sprite = await gameRef.loadSprite('ancestor_carrot.png');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // Tap feedback effect (subtle scale down and pop back up)
    add(
      ScaleEffect.to(
        Vector2.all(0.96),
        EffectController(duration: 0.05, reverseDuration: 0.05),
      ),
    );

    // MVVM Logic: Reward points based on the tap upgrade level
    int joyReward = 1 + gameRef.viewModel.tapLevel;
    gameRef.viewModel.addJoy(joyReward);

    // Spawns the floating text cleanly above the massive 928px tall carrot crown
    gameRef.world.add(
      FloatingText(
        '+$joyReward Joy',
        Vector2(position.x, position.y - (size.y / 2) - 30),
      ),
    );
  }
}
