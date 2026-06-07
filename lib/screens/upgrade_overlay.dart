import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';
import '../game/bunny_game.dart';

class UpgradeOverlay extends StatelessWidget {
  final BunnyGame game;
  const UpgradeOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, viewModel, child) {
        int nextTapCost = viewModel.calculateTapUpgradeCost();
        bool canAffordTap = viewModel.joy >= nextTapCost;
        bool canAffordExpansion = viewModel.joy >= viewModel.expansionCost;

        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- TAP POWER UPGRADE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tap Power (Lv. ${viewModel.tapLevel})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Yields +${viewModel.tapLevel + 2} per tap',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        // Tell the ViewModel to buy it!
                        onPressed: canAffordTap
                            ? () => viewModel.buyTapUpgrade()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                        ),
                        child: Text(
                          canAffordTap
                              ? 'Buy: 🥕$nextTapCost'
                              : 'Locked: 🥕$nextTapCost',
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // --- BURROW EXPANSION UPGRADE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dig Deeper (Stage ${viewModel.burrowLevel + 1})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Unlocks more grid space',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (viewModel.burrowLevel < 3)
                        ElevatedButton(
                          onPressed: canAffordExpansion
                              ? () {
                                  // Tell the ViewModel to process the purchase
                                  bool success = viewModel.buyBurrowExpansion();
                                  // If successful, tell Flame to animate the dirt!
                                  if (success) {
                                    game.unlockNextStage();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5A2B),
                          ),
                          child: Text(
                            canAffordExpansion
                                ? 'Dig: 🥕${viewModel.expansionCost}'
                                : 'Locked: 🥕${viewModel.expansionCost}',
                          ),
                        )
                      else
                        const Text(
                          'MAX DEPTH',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
