import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'wander_zone.dart';

class BurrowDoorComponent extends PositionComponent {
  // Now it holds a list!
  final List<WanderZone> targetZones;

  BurrowDoorComponent({
    required this.targetZones,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size) {
    add(RectangleHitbox(isSolid: true));
  }
}
