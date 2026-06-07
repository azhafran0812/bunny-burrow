import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../viewmodels/game_viewmodel.dart'; 

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
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
                // We ask the ViewModel for the current joy!
                '🥕 ${viewModel.joy} Joy',
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
