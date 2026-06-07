import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class FloatingText extends TextComponent {
  FloatingText(String text, Vector2 spawnPosition)
    : super(
        text: text,
        position: spawnPosition,
        anchor: Anchor.center,
        priority: 100,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black45,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 1. The Float Effect: Move up 70 pixels over 0.6 seconds
    add(MoveEffect.by(Vector2(0, -70), EffectController(duration: 0.6)));

    // 2. The Cleanup Effect: Safely destroys the component after 0.6 seconds
    // This prevents memory leaks without relying on opacity fading!
    add(RemoveEffect(delay: 0.6));
  }
}
