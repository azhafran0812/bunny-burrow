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
    
    add(ScaleEffect.to(Vector2.all(0.9), EffectController(duration: 0.1, reverseDuration: 0.1)));

    final box = Hive.box('playerData');
    int currentJoy = box.get('joy', defaultValue: 0);
    int tapLevel = box.get('tap_level', defaultValue: 0);
    int joyReward = 1 + tapLevel; 
    box.put('joy', currentJoy + joyReward);

    // --- CRITICAL FIX HERE ---
    // 1. We use gameRef.world.add so it goes into the dirt environment.
    // 2. We use the Carrot's position (offset slightly up) instead of the screen touch!
    gameRef.world.add(
      FloatingText('+$joyReward Joy', Vector2(position.x, position.y - 60)),
    );
  }
}
