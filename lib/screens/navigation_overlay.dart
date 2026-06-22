import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../game/bunny_game.dart';

class NavigationOverlay extends StatelessWidget {
  final BunnyGame game;
  const NavigationOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // How many pixels the camera moves per button tap
    const double panSpeed = 150.0;

    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 16.0,
            bottom: 100.0,
          ), // Kept above the upgrade menu
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up, size: 32),
                  onPressed: () => game.panCamera(Vector2(0, -panSpeed)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left, size: 32),
                      onPressed: () => game.panCamera(Vector2(-panSpeed, 0)),
                    ),
                    const SizedBox(width: 32), // Empty space in the middle
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_right, size: 32),
                      onPressed: () => game.panCamera(Vector2(panSpeed, 0)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                  onPressed: () => game.panCamera(Vector2(0, panSpeed)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
