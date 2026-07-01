import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlacementNode extends PositionComponent {
  final String furnitureType;
  bool isOccupied = false;
  PositionComponent? placedFurniture;

  PlacementNode({
    required this.furnitureType,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    // Temporary visual debug to ensure Tiled placement is correct
    // (You can delete this render method later)
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(size.toRect(), paint);
  }

  // We will call this method when the player buys an item
  void placeFurniture(PositionComponent furniture) {
    if (!isOccupied) {
      placedFurniture = furniture;
      isOccupied = true;

      // Force the furniture to sit perfectly in the center of your Tiled node
      furniture.position = Vector2(size.x / 2, size.y / 2);
      furniture.anchor = Anchor.center;

      add(furniture); // Make the furniture a child of this specific node
      print("Placed a ${furniture.runtimeType} on node type: $furnitureType");
    }
  }
}
