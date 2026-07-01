import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'dart:math';

import '../components/ancestor_carrot.dart';
import '../components/furniture_component.dart';
import '../models/furniture_model.dart';
import '../components/dirt_block.dart';
import '../viewmodels/game_viewmodel.dart';
import '../components/burrow_door.dart';
import '../components/bunny_component.dart';
import '../components/wander_zone.dart';
import '../components/bridge_component.dart';
import '../utils/constants.dart';

class BunnyGame extends FlameGame
    with WidgetsBindingObserver, PanDetector, ScrollDetector, HasCollisionDetection {
  final GameViewModel viewModel;
  BunnyGame(this.viewModel);

  double _secondTicker = 0.0;
  final int maxOfflineSeconds = 12 * 60 * 60;
  int lastOfflineEarnings = 0;

  // --- MAP DIMENSIONS ---
  final double mapWidth = 2250.0;
  final double mapHeight = 5000.0;
  final double stage1Depth = 1863.0;
  final double stage2Depth = 3535.0; // 1863 + 1672
  final double stage3Depth = 5000.0; // 3535 + 1465

  // --- GRID ARCHITECTURE ---
  final double tileSize = 64.0;
  final int gridColumns = 6;
  final int gridRows = 4;
  late Vector2 gridOrigin;

  @override
  Color backgroundColor() => const Color(0xFF1A1A1A); // Dark void behind the map

  @override
  Future<void> onLoad() async {
    super.onLoad();
    WidgetsBinding.instance.addObserver(this);
    camera.viewfinder.anchor = Anchor.topLeft;

    
    final bgSprite = await loadSprite('warren_bg.png');
    world.add(
      SpriteComponent(
        sprite: bgSprite,
        size: Vector2(mapWidth, mapHeight),
        position: Vector2.zero(),
      ),
    );

    
    gridOrigin = Vector2((mapWidth - (gridColumns * tileSize)) / 2, 800);

    _calculateOfflineEarnings();
    _loadPlacedFurniture();
    _generateDirtBlocks();

    final tiledMap = await TiledComponent.load('map.tmx', Vector2.all(25));

    final Map<String, WanderZone> loadedZones = {};

final objectGroup = tiledMap.tileMap.getLayer<ObjectGroup>('WanderZones');

if (objectGroup != null) {
  for (final obj in objectGroup.objects) {
    if (obj.isPolygon && obj.polygon.isNotEmpty) {
      
      final path = Path();
      
      // Move to the very first point's absolute global position
      path.moveTo(obj.x + obj.polygon[0].x, obj.y + obj.polygon[0].y);
      
      // Trace the rest of the lines
      for (int i = 1; i < obj.polygon.length; i++) {
        path.lineTo(obj.x + obj.polygon[i].x, obj.y + obj.polygon[i].y);
      }
      
      // Close the loop to finish the shape
      path.close();

      final zone = WanderZone(
        stageLevel: obj.properties.getValue('stageLevel') ?? 1,
        path: path,
      );
      
      zone.priority = 10; // Draw above the background
      loadedZones[obj.name] = zone;
      await world.add(zone); 
    }
  }

      camera.viewfinder.position = Vector2(
        500,
        1000,
      ); // Adjust these to your map's center
      camera.viewfinder.anchor = Anchor.topLeft;
      
    }
    
    final bridgeGroup = tiledMap.tileMap.getLayer<ObjectGroup>('Bridges');
    if (bridgeGroup != null) {
      for (final obj in bridgeGroup.objects) {
        // Get the strings you typed in Tiled
        final zoneAName = obj.properties.getValue<String>('zoneA');
        final zoneBName = obj.properties.getValue<String>('zoneB');

        // Look them up in our dictionary
        final zoneA = loadedZones[zoneAName];
        final zoneB = loadedZones[zoneBName];

        // If we found both zones successfully, build the bridge!
        if (zoneA != null && zoneB != null) {
          final bridge = BridgeComponent(
            zoneA: zoneA,
            zoneB: zoneB,
            position: Vector2(obj.x, obj.y),
            size: Vector2(obj.width, obj.height),
          );

          // Don't forget to add it to the world
          await world.add(bridge);
          print(
            "Successfully created bridge between $zoneAName and $zoneBName",
          );
        } else {
          print(
            "Error: Could not find zones $zoneAName or $zoneBName for the bridge.",
          );
        }
      }
    }


    final ancestorCarrot = AncestorCarrot();

    // Translating your top-left coordinates (849, 376) to match the center-anchored component math
    double centerX = 849.0 + (701.0 / 2);
    double centerY = 376.0 + (928.0 / 2);

    ancestorCarrot.position = Vector2(centerX, centerY);
    world.add(ancestorCarrot);

    // SETUP DOORS (Adjusted for the new 2250x5000 scale)
    world.add(
      BurrowDoor(
        stageLevel: 1,
        position: Vector2(mapWidth / 2, stage1Depth - 100), // Bottom of Stage 1
        teleportDestination: Vector2(
          mapWidth / 2,
          stage1Depth + 150,
        ), // Top of Stage 2
        destinationStage: 2,
      ),
    );

    world.add(
      BurrowDoor(
        stageLevel: 2,
        position: Vector2(mapWidth / 2, stage1Depth + 150),
        teleportDestination: Vector2(mapWidth / 2, stage1Depth - 100),
        destinationStage: 1,
      ),
    );

    spawnBunny(BunnyBreed.americanfuzzylop, 1);
    spawnBunny(BunnyBreed.hollandlop, 1);
    spawnBunny(BunnyBreed.lop, 1);

    debugMode = true;
  }

  void spawnBunny(BunnyBreed breed, int targetStage) {
    // 1. Find all zones that belong to the target stage
    final validZones = world.children
        .whereType<WanderZone>()
        .where((zone) => zone.stageLevel == targetStage)
        .toList();

    if (validZones.isNotEmpty) {
      // 2. Pick a random zone from that stage to be the bunny's "home" zone
      final startingZone = validZones[Random().nextInt(validZones.length)];

      // 3. Create the bunny and inject the breed and zone
      final bunny = BunnyComponent(breed: breed, currentZone: startingZone);

      world.add(bunny);
    } else {
      print("Error: No WanderZones found for stage $targetStage!");
    }
  }

  void _loadPlacedFurniture() {
    final box = Hive.box('playerData');
    final List<dynamic> savedItems = box.get(
      'furniture_layout',
      defaultValue: [],
    );
    int currentPassiveRate = 0;

    for (var rawMap in savedItems) {
      final model = FurnitureModel.fromMap(rawMap as Map);
      currentPassiveRate += model.passiveYield;
      final component = FurnitureComponent(model: model, tileSize: tileSize);
      component.position += gridOrigin;
      world.add(component);
    }
    box.put('passive_rate', currentPassiveRate);
  }

  bool verifyAndPlaceFurniture(FurnitureModel newItem) {
    final box = Hive.box('playerData');
    final List<dynamic> savedItems = box.get(
      'furniture_layout',
      defaultValue: [],
    );

    if (newItem.gridX < 0 ||
        newItem.gridX + newItem.width > gridColumns ||
        newItem.gridY < 0 ||
        newItem.gridY + newItem.height > gridRows)
      return false;

    for (var rawMap in savedItems) {
      final existing = FurnitureModel.fromMap(rawMap as Map);
      bool overlapX =
          newItem.gridX < existing.gridX + existing.width &&
          newItem.gridX + newItem.width > existing.gridX;
      bool overlapY =
          newItem.gridY < existing.gridY + existing.height &&
          newItem.gridY + newItem.height > existing.gridY;
      if (overlapX && overlapY) return false;
    }

    savedItems.add(newItem.toMap());
    box.put('furniture_layout', savedItems);
    _loadPlacedFurniture();
    return true;
  }

  @override
  void onRemove() {
    WidgetsBinding.instance.removeObserver(this);
    super.onRemove();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      Hive.box(
        'playerData',
      ).put('last_exit_time', DateTime.now().millisecondsSinceEpoch);
    } else if (state == AppLifecycleState.resumed) {
      _calculateOfflineEarnings();
    }
  }

  void _calculateOfflineEarnings() {
    final box = Hive.box('playerData');
    int lastExitTime = box.get('last_exit_time', defaultValue: 0);
    int passiveRate = box.get('passive_rate', defaultValue: 0);

    if (lastExitTime == 0) return;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int timeDeltaSeconds = ((currentTime - lastExitTime) / 1000).floor();
    if (timeDeltaSeconds < 0) return;
    if (timeDeltaSeconds > maxOfflineSeconds)
      timeDeltaSeconds = maxOfflineSeconds;

    int offlineEarnings = timeDeltaSeconds * passiveRate;
    if (offlineEarnings > 0) {
      int currentJoy = box.get('joy', defaultValue: 0);
      box.put('joy', currentJoy + offlineEarnings);
      lastOfflineEarnings = offlineEarnings;
      overlays.add('WelcomeBackOverlay');
    }
    box.put('last_exit_time', currentTime);
  }

@override
  void update(double dt) {
    super.update(dt);
    _secondTicker += dt;
    if (_secondTicker >= 1.0) {
      _secondTicker -= 1.0;
      final box = Hive.box('playerData');
      int passiveRate = box.get('passive_rate', defaultValue: 0);
      if (passiveRate > 0) {
        int currentJoy = box.get('joy', defaultValue: 0);
        box.put('joy', currentJoy + passiveRate);
      }
    }

    // --- ABSOLUTE CAMERA LOCK ---
    // Enforcing this here guarantees that no matter what tries to move the camera
    // (D-pad, mouse drag, or animation), it can NEVER render outside the background!
    _clampCamera();
  }

  // --- ALIGNED DIRT BLOCKS ---
  void _generateDirtBlocks() {
    final box = Hive.box('playerData');
    int currentLevel = box.get('burrow_level', defaultValue: 1);

    double blockSize =
        150.0; // Larger blocks to improve rendering speed on a massive map
    int cols = (mapWidth / blockSize).ceil();

    // Stage 2 (1863 to 3535)
    if (currentLevel < 2) {
      int rows = (1672 / blockSize).ceil();
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          world.add(
            DirtBlock(
              stage: 2,
              position: Vector2(c * blockSize, stage1Depth + (r * blockSize)),
              size: Vector2(blockSize + 1, blockSize + 1),
            ),
          );
        }
      }
    }

    // Stage 3 (3535 to 5000)
    if (currentLevel < 3) {
      int rows = (1465 / blockSize).ceil();
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          world.add(
            DirtBlock(
              stage: 3,
              position: Vector2(c * blockSize, stage2Depth + (r * blockSize)),
              size: Vector2(blockSize + 1, blockSize + 1),
            ),
          );
        }
      }
    }
  }

void unlockNextStage() {
    final box = Hive.box('playerData');
    // The ViewModel already upgraded the database! We just read the new level here.
    int currentLevel = box.get('burrow_level', defaultValue: 1);

    // Animate the dirt blocks crumbling for the CURRENT level we just unlocked
    world.children
        .whereType<DirtBlock>()
        .where((block) => block.stage == currentLevel)
        .forEach((block) {
          block.crumble();
        });

    // Pan the camera down to the newly unlocked stage
    double targetY = currentLevel == 2 ? stage1Depth : stage2Depth;

    camera.viewfinder.add(
      MoveEffect.to(
        Vector2(camera.viewfinder.position.x, targetY - (size.y / 3)),
        EffectController(duration: 1.5, curve: Curves.easeInOut),
      ),
    );

    debugPrint("Visuals updated for Stage $currentLevel!");
  }

  // --- THE NEW SCROLL & ZOOM MATH ---
  void _clampCamera() {
    final box = Hive.box('playerData');
    int currentLevel = box.get('burrow_level', defaultValue: 1);

    double currentMaxDepth = stage1Depth;
    if (currentLevel == 2) currentMaxDepth = stage2Depth;
    if (currentLevel >= 3) currentMaxDepth = stage3Depth;

    // Adjust limits based on how far we are zoomed in!
    double maxScrollX = mapWidth - (size.x / camera.viewfinder.zoom);
    double maxScrollY = currentMaxDepth - (size.y / camera.viewfinder.zoom);

    if (maxScrollX < 0) maxScrollX = 0;
    if (maxScrollY < 0) maxScrollY = 0;

    if (camera.viewfinder.position.x < 0)
      camera.viewfinder.position.x = 0;
    else if (camera.viewfinder.position.x > maxScrollX)
      camera.viewfinder.position.x = maxScrollX;

    if (camera.viewfinder.position.y < 0)
      camera.viewfinder.position.y = 0;
    else if (camera.viewfinder.position.y > maxScrollY)
      camera.viewfinder.position.y = maxScrollY;
  }

  // 1. CLICK AND DRAG TO PAN (NOW WITH X AND Y!)
  @override
  void onPanUpdate(DragUpdateInfo info) {
    // If you are zoomed in, the drag speed needs to scale with the zoom
    double zoomScale = camera.viewfinder.zoom;
    camera.viewfinder.position.x -= info.delta.global.x / zoomScale;
    camera.viewfinder.position.y -= info.delta.global.y / zoomScale;
    _clampCamera();
  }


// 2. MOUSE WHEEL TO ZOOM IN AND OUT!
  @override
  void onScroll(PointerScrollInfo info) {
    double zoomDelta = info.scrollDelta.global.y > 0 ? -0.1 : 0.1;
    double newZoom = camera.viewfinder.zoom + zoomDelta;

    // --- DYNAMIC ZOOM LIMITER ---
    // Figure out the current maximum depth based on burrow level
    final box = Hive.box('playerData');
    int currentLevel = box.get('burrow_level', defaultValue: 1);
    double currentMaxDepth = stage1Depth;
    if (currentLevel == 2) currentMaxDepth = stage2Depth;
    if (currentLevel >= 3) currentMaxDepth = stage3Depth;

    // Calculate the absolute minimum zoom allowed for both X and Y
    double minZoomX = size.x / mapWidth;
    double minZoomY = size.y / currentMaxDepth;

    // Pick whichever limit is stricter so the void is NEVER visible
    double minZoom = minZoomX > minZoomY ? minZoomX : minZoomY;

    if (newZoom < minZoom) newZoom = minZoom;
    if (newZoom > 2.0) newZoom = 2.0; // Max zoom in

    camera.viewfinder.zoom = newZoom;
    _clampCamera();
  }

// --- UPDATED D-PAD PANNING ---
  void panCamera(Vector2 delta) {
// 1. Move the camera
    camera.viewfinder.position += delta / camera.viewfinder.zoom;

    // 2. INSTANTLY lock it before the screen renders!
    _clampCamera();
  }
}
