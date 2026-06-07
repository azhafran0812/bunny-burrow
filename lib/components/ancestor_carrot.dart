import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../game/bunny_game.dart';
import 'floating_text.dart';

class AncestorCarrot extends CircleComponent
    with TapCallbacks, HasGameRef<BunnyGame> {
  AncestorCarrot()
    : super(
        radius: 120,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFFFF8C00),
      );

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    add(
      ScaleEffect.to(
        Vector2.all(0.9),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      ),
    );

    // --- NEW MVVM LOGIC ---
    // Calculate the reward using the ViewModel's tap level
    int joyReward = 1 + gameRef.viewModel.tapLevel;

    // Tell the ViewModel to add the joy!
    gameRef.viewModel.addJoy(joyReward);

    gameRef.world.add(
      FloatingText('+$joyReward Joy', Vector2(position.x, position.y - 60)),
    );
  }
}
