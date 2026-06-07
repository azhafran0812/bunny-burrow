import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../game/bunny_game.dart';

class HudOverlay extends StatelessWidget {
  final BunnyGame game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // This listens to the 'joy' key in the database.
    // Whenever it changes, this widget rebuilds automatically!
    return ValueListenableBuilder(
      valueListenable: Hive.box('playerData').listenable(keys: ['joy']),
      builder: (context, Box box, _) {
        final joy = box.get('joy', defaultValue: 0);

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.85,
                ), // Soft, readable background
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '🥕 $joy Joy',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
