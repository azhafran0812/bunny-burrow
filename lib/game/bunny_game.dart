import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../components/ancestor_carrot.dart';
import '../components/furniture_component.dart';
import '../models/furniture_model.dart';
import '../components/dirt_block.dart';
import '../viewmodels/game_viewmodel.dart';

class BunnyGame extends FlameGame
    with WidgetsBindingObserver, PanDetector, ScrollDetector {
      final GameViewModel viewModel;
      BunnyGame(this.viewModel);
  double _secondTicker = 0.0;
  final int maxOfflineSeconds = 12 * 60 * 60;
  int lastOfflineEarnings = 0;

  // --- GRID ARCHITECTURE SPECIFICATIONS ---
  final double tileSize = 64.0;
  final int gridColumns = 6;
  final int gridRows = 4;
  late Vector2 gridOrigin;

  @override
  Color backgroundColor() => const Color(0xFF8B5A2B);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    WidgetsBinding.instance.addObserver(this);

    // 1. Lock the camera to the top-left of the screen
    camera.viewfinder.anchor = Anchor.topLeft;

    gridOrigin = Vector2((size.x - (gridColumns * tileSize)) / 2, 150);

    _calculateOfflineEarnings();
    _loadPlacedFurniture();
    _generateDirtBlocks();

    final ancestorCarrot = AncestorCarrot();
    ancestorCarrot.position = Vector2(size.x / 2, size.y / 2 + 200);

    // 2. CRITICAL FIX: Add the carrot to the WORLD, not the screen glass!
    world.add(ancestorCarrot);
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

      // CRITICAL FIX: Add furniture to the WORLD
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
        newItem.gridY + newItem.height > gridRows) {
      return false;
    }

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
  }

  // --- THE DIRT BLOCK LOGIC ---
  void _generateDirtBlocks() {
    final box = Hive.box('playerData');
    int currentLevel = box.get('burrow_level', defaultValue: 1);

    double blockSize = 100.0;
    int cols = (size.x / blockSize).ceil();

    if (currentLevel < 2) {
      for (int r = 0; r < 7; r++) {
        for (int c = 0; c < cols; c++) {
          // CRITICAL FIX: Add to WORLD
          world.add(
            DirtBlock(
              stage: 2,
              position: Vector2(c * blockSize, 900.0 + (r * blockSize)),
              size: Vector2(blockSize + 1, blockSize + 1),
            ),
          );
        }
      }
    }

    if (currentLevel < 3) {
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < cols; c++) {
          // CRITICAL FIX: Add to WORLD
          world.add(
            DirtBlock(
              stage: 3,
              position: Vector2(c * blockSize, 1600.0 + (r * blockSize)),
              size: Vector2(blockSize + 1, blockSize + 1),
            ),
          );
        }
      }
    }
  }

  // --- UPDATED EXPANSION LOGIC ---
  void unlockNextStage() {
    final box = Hive.box('playerData');
    int currentLevel = box.get('burrow_level', defaultValue: 1);
    
    if (currentLevel >= 3) return;

    int nextLevel = currentLevel + 1;
    box.put('burrow_level', nextLevel); 

    world.children.whereType<DirtBlock>().where((block) => block.stage == nextLevel).forEach((block) {
      block.crumble();
    });
    
    // The top of the new stage
    double targetY = nextLevel == 2 ? 900.0 : 1600.0;
    
    // CRITICAL FIX: Use MoveEffect.to() instead of MoveToEffect()
    camera.viewfinder.add(
      MoveEffect.to(
        Vector2(0, targetY - (size.y / 3)), // Scrolls down so the new area is visible
        EffectController(duration: 1.5, curve: Curves.easeInOut),
      ),
    );

    debugPrint("Stage $nextLevel Unlocked!");
  }

// --- UPDATED SCROLL MATH FOR DESKTOP EMULATORS ---
  void _clampCamera() {
    final box = Hive.box('playerData');
    int currentLevel = box.get('burrow_level', defaultValue: 1);

    // 1. MASSIVELY increased depths so large PC screens don't trap the camera!
    double maxDepth = 2500.0; // Level 1 Depth
    if (currentLevel == 2) maxDepth = 4000.0; // Level 2 Depth
    if (currentLevel >= 3) maxDepth = 6000.0; // Level 3 Depth

    // 2. Calculate the limit
    double maxScroll = maxDepth - size.y;
    if (maxScroll < 0) maxScroll = 0;

    // 3. Clamp the movement
    if (camera.viewfinder.position.y < 0) {
      camera.viewfinder.position.y = 0;
    } else if (camera.viewfinder.position.y > maxScroll) {
      camera.viewfinder.position.y = maxScroll;
    }
  }

  // Handles Touch Screens (Click and drag)
  @override
  void onPanUpdate(DragUpdateInfo info) {
    camera.viewfinder.position.y -= info.delta.global.y;
    _clampCamera();
  }

  // Handles Mouse Wheels (Edge / Chrome)
  @override
  void onScroll(PointerScrollInfo info) {
    // Multiplied the scrollDelta by 3.0 so the mouse wheel feels much faster!
    camera.viewfinder.position.y += info.scrollDelta.global.y * 3.0;
    _clampCamera();
  }
}