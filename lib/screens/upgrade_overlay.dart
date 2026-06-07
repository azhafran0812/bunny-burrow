import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../game/bunny_game.dart';

class UpgradeOverlay extends StatelessWidget {
  final BunnyGame game;
  const UpgradeOverlay({super.key, required this.game});

  // Balanced mathematical parameters
  final int baseCost = 10;
  final double costMultiplier = 1.15;

  int calculateCost(int currentLevel) {
    return (baseCost * pow(costMultiplier, currentLevel)).toInt();
  }

  void buyUpgrade(Box box, int cost, int currentLevel) {
    int currentJoy = box.get('joy', defaultValue: 0);
    if (currentJoy >= cost) {
      box.put('joy', currentJoy - cost);
      box.put('tap_level', currentLevel + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(
        'playerData',
      ).listenable(keys: ['joy', 'tap_level']),
      builder: (context, Box box, _) {
        int currentJoy = box.get('joy', defaultValue: 0);
        int tapLevel = box.get('tap_level', defaultValue: 0);
        int nextCost = calculateCost(tapLevel);
        bool canAfford = currentJoy >= nextCost;
        int burrowLevel = box.get('burrow_level', defaultValue: 1);
        int expansionCost = burrowLevel == 1
            ? 500
            : 5000; // Stage 2 is 500, Stage 3 is 5000
        bool canAffordExpansion = currentJoy >= expansionCost;

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
                // Changed to Column to stack the two upgrades
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
                            'Tap Power (Lv. $tapLevel)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Yields +${tapLevel + 2} per tap',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: canAfford
                            ? () => buyUpgrade(box, nextCost, tapLevel)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                        ),
                        child: Text(
                          canAfford
                              ? 'Buy: 🥕$nextCost'
                              : 'Locked: 🥕$nextCost',
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
                            'Dig Deeper (Stage ${burrowLevel + 1})',
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
                      if (burrowLevel < 3)
                        ElevatedButton(
                          onPressed: canAffordExpansion
                              ? () {
                                  box.put(
                                    'joy',
                                    currentJoy - expansionCost,
                                  ); // Deduct Joy
                                  game.unlockNextStage(); // Trigger the animation!
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5A2B),
                          ),
                          child: Text(
                            canAffordExpansion
                                ? 'Dig: 🥕$expansionCost'
                                : 'Locked: 🥕$expansionCost',
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
