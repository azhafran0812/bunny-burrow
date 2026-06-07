import 'package:flutter/material.dart';
import '../game/bunny_game.dart';

class WelcomeBackOverlay extends StatelessWidget {
  final BunnyGame game;
  const WelcomeBackOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // A semi-transparent dark background to focus the player's attention
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Keeps the box snug around the content
            children: [
              const Text('💤 🐰', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5A2B), // Brown to match the dirt theme
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'While you were away, your bunnies foraged:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // This reads the variable we just saved in the game engine!
              Text(
                '+${game.lastOfflineEarnings} Joy 🥕',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF8C00),
                ),
              ),
              const SizedBox(height: 24),

              // The Collect Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // This tells Flame to close the overlay and resume normal gameplay
                    game.overlays.remove('WelcomeBackOverlay');
                  },
                  child: const Text(
                    'Collect',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
