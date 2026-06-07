import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'game/bunny_game.dart';
import 'screens/hud_overlay.dart';
import 'screens/upgrade_overlay.dart';
import 'screens/welcome_back_overlay.dart';
import 'repositories/player_repository.dart';
import 'viewmodels/game_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('playerData');

  // 1. Initialize the MVVM Architecture
  final repository = PlayerRepository();
  final viewModel = GameViewModel(repository);

  runApp(
    // 2. Wrap the app in the Provider so all UI screens can listen to it
    ChangeNotifierProvider.value(value: viewModel, child: const BunnyApp()),
  );
}

class BunnyApp extends StatelessWidget {
  const BunnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Grab the ViewModel to pass it down into the Flame Game engine
    final viewModel = Provider.of<GameViewModel>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bunny Burrow',
      home: Scaffold(
        body: GameWidget(
          // 3. Inject the ViewModel into the game engine
          game: BunnyGame(viewModel),
          overlayBuilderMap: {
            // Notice how HudOverlay no longer needs parameters! Provider handles it.
            'HudOverlay': (context, BunnyGame game) => const HudOverlay(),
            'UpgradeOverlay': (context, BunnyGame game) =>
                UpgradeOverlay(game: game),
            'WelcomeBackOverlay': (context, BunnyGame game) =>
                WelcomeBackOverlay(game: game),
          },
          initialActiveOverlays: const ['HudOverlay', 'UpgradeOverlay'],
        ),
      ),
    );
  }
}
