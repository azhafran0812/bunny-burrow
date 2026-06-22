import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart'; // 1. ADD THIS IMPORT!

import 'game/bunny_game.dart';
import 'screens/hud_overlay.dart';
import 'screens/upgrade_overlay.dart';
import 'screens/navigation_overlay.dart';
import 'screens/welcome_back_overlay.dart';
import 'repositories/player_repository.dart';
import 'viewmodels/game_viewmodel.dart';

// 2. ADD THIS CUSTOM BEHAVIOR CLASS
class GameScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind
        .mouse, // <--- This is the magic line that allows mouse dragging!
    PointerDeviceKind.trackpad, // Allows laptop trackpad dragging
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
// Open the box and save it to a variable temporarily
  final box = await Hive.openBox('playerData');

  // --- ADD THIS LINE TO NUKE THE SAVE FILE ---
  await box.clear();

  final repository = PlayerRepository();
  final viewModel = GameViewModel(repository);

  runApp(
    ChangeNotifierProvider.value(value: viewModel, child: const BunnyApp()),
  );
}

class BunnyApp extends StatelessWidget {
  const BunnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bunny Burrow',

      // 3. APPLY THE BEHAVIOR HERE
      scrollBehavior: GameScrollBehavior(),

      home: Scaffold(
        body: GameWidget(
          game: BunnyGame(viewModel),
          overlayBuilderMap: {
            'HudOverlay': (context, BunnyGame game) => const HudOverlay(),
            'UpgradeOverlay': (context, BunnyGame game) =>
                UpgradeOverlay(game: game),
            'WelcomeBackOverlay': (context, BunnyGame game) =>
                WelcomeBackOverlay(game: game),
            'NavigationOverlay': (context, BunnyGame game) =>
                NavigationOverlay(game: game),
          },
          initialActiveOverlays: const ['HudOverlay', 'UpgradeOverlay',
            'NavigationOverlay'
          ],
        ),
      ),
    );
  }
}
