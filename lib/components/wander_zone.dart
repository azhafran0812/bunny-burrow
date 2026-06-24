import 'dart:math';
import 'package:flame/components.dart';

class WanderZone extends PositionComponent {
  final int stageLevel; // Which stage this zone belongs to

  
  final Random _random = Random();

  WanderZone({
    required this.stageLevel,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  // Helper method for the bunny to get a random X/Y coordinate inside this specific box
  Vector2 getRandomPointInside() {
    // Uses the component's width, height, and top-left position
    double randomX =
        position.x +
        (size.x *
            (0.1 +
                0.8 *
                    _random
                        .nextDouble())); // Keeps them slightly off the very edges
    double randomY = position.y + (size.y * (0.1 + 0.8 * _random.nextDouble()));

    return Vector2(randomX, randomY);
  }
}
