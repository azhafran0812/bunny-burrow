import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/furniture_model.dart';

class FurnitureComponent extends PositionComponent {
  final FurnitureModel model;
  final double tileSize;

  FurnitureComponent({required this.model, required this.tileSize})
    : super(
        // Calculate screen bounds based on tile matrices
        size: Vector2(model.width * tileSize, model.height * tileSize),
        anchor: Anchor.topLeft,
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    refreshPosition();

    // Grey-box layout placeholder shape matching the item dimensions
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color =
              const Color(0xFFCD853F) // Warm wood tone
          ..style = PaintingStyle.fill,
      ),
    );
  }

  // Updates the actual screen coordinates whenever data indices shift
  void refreshPosition() {
    position = Vector2(model.gridX * tileSize, model.gridY * tileSize);
  }
}
