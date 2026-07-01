import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WanderZone extends Component {
  final int stageLevel;
  final Path path;

  WanderZone({required this.stageLevel, required this.path});

  @override
  void render(Canvas canvas) {
    // This is just for debugMode so you can see it
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, paint);
  }

  // Flutter's Path has a built-in exact contains check!
  bool containsPoint(Vector2 point) {
    return path.contains(Offset(point.x, point.y));
  }

  // Generate a random point inside this exact shape
  Vector2 getRandomPointInside() {
    final bounds = path.getBounds();
    final random = Random();
    Vector2 randomPoint;

    do {
      randomPoint = Vector2(
        bounds.left + random.nextDouble() * bounds.width,
        bounds.top + random.nextDouble() * bounds.height,
      );
    } while (!containsPoint(randomPoint));

    return randomPoint;
  }
}
