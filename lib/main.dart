import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'game/bunny_game.dart';
import 'screens/hud_overlay.dart';
import 'screens/upgrade_overlay.dart';
import 'screens/welcome_back_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('playerData');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bunny Burrow',
      home: Scaffold(
        // We use overlayBuilderMap to stack Flutter UI on top of Flame
        body: GameWidget(
          game: BunnyGame(),
          overlayBuilderMap: {
            'HudOverlay': (context, BunnyGame game) => HudOverlay(game: game),
            'UpgradeOverlay': (context, BunnyGame game) => UpgradeOverlay(game: game),
            'WelcomeBackOverlay': (context, BunnyGame game) => WelcomeBackOverlay(game: game),
          },
          initialActiveOverlays: const ['HudOverlay', 'UpgradeOverlay'], 
        ),
      ),
    ),
  );
}
