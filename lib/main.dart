import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart'; 

import 'game/bunny_game.dart';
import 'screens/hud_overlay.dart';
import 'screens/main_hud_overlay.dart';
import 'screens/upgrade_overlay.dart';
import 'screens/navigation_overlay.dart';
import 'screens/welcome_back_overlay.dart';
import 'repositories/player_repository.dart';
import 'viewmodels/game_viewmodel.dart';


class GameScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind
        .mouse, 
    PointerDeviceKind.trackpad,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
// Open the box and save it to a variable temporarily
  final box = await Hive.openBox('playerData');

  // --- NUKE THE SAVE FILE ---
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

      
      scrollBehavior: GameScrollBehavior(),

      home: Scaffold(
        body: GameWidget(
          game: BunnyGame(viewModel),
          overlayBuilderMap: {
            'MainHudOverlay': (context, BunnyGame game) =>
                MainHudOverlay(game: game),
            'NavigationOverlay': (context, BunnyGame game) =>
                NavigationOverlay(game: game),
            'WelcomeBackOverlay': (context, BunnyGame game) =>
                WelcomeBackOverlay(game: game),
          },
          initialActiveOverlays: const ['MainHudOverlay', 'NavigationOverlay'],
        ),
      ),
    );
  }
}
