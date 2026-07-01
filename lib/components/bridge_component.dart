import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'wander_zone.dart';

class BridgeComponent extends PositionComponent {
  final WanderZone zoneA;
  final WanderZone zoneB;
  final int targetStageLevel;

  BridgeComponent({
    required this.zoneA,
    required this.zoneB,
    required this.targetStageLevel,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size) {
    // This adds a rectangular physics body to the bridge
    add(RectangleHitbox(isSolid: true));
  }
}
