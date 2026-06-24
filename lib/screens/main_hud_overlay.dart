import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';
import '../game/bunny_game.dart';

class MainHudOverlay extends StatefulWidget {
  final BunnyGame game;
  const MainHudOverlay({super.key, required this.game});

  @override
  State<MainHudOverlay> createState() => _MainHudOverlayState();
}

class _MainHudOverlayState extends State<MainHudOverlay> {
  bool isTrayExpanded = false;

  // --- 1. ADD THIS CONTROLLER ---
  final ScrollController _scrollController = ScrollController();

  // --- 2. ADD THIS TO CLEAN UP MEMORY ---
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();

    return SafeArea(
      child: Stack(
        children: [
          // ==========================================
          // 1. THE TOP BAR (CURRENCIES)
          // ==========================================
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCurrencyBadge(
                  'assets/images/icon_heart.png',
                  viewModel.joy.toString(),
                  Colors.pinkAccent,
                ),
                _buildCurrencyBadge(
                  'assets/images/icon_flower.png',
                  viewModel.flowers.toString(),
                  Colors.green,
                ),
                _buildCurrencyBadge(
                  'assets/images/icon_carrot.png',
                  viewModel.carrots.toString(),
                  Colors.orange,
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. SIDE MENU BUTTONS (RIGHT SIDE)
          // ==========================================
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => debugPrint("Opened Bunnypedia!"),
                  child: Image.asset(
                    'assets/images/notebook_btn.png',
                    width: 75,
                    height: 75,
                    errorBuilder: (context, error, stackTrace) =>
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.book,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => debugPrint("Opened Shop!"),
                  child: Image.asset(
                    'assets/images/bag_btn.png',
                    width: 75,
                    height: 75,
                    errorBuilder: (context, error, stackTrace) =>
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.brown,
                          child: Icon(
                            Icons.shopping_bag,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 3. TRAY LOGIC (CLOSED VS EXPANDED)
          // ==========================================
          if (isTrayExpanded)
            _buildOpenedTray(viewModel)
          else
            _buildClosedTray(),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildClosedTray() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => setState(() => isTrayExpanded = true),
        child: Image.asset(
          'assets/images/hud_closed_tray.png',
          width: 340, 
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 100,
            height: 140,
            decoration: const BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpenedTray(GameViewModel viewModel) {
    return Center(
      // Puts the entire menu dead-center on the screen
      child: Container(
        width: 350,
        height: 550,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/hud_opened_tray.png',
            ), // Ensure this is jpg or png based on your file
            fit: BoxFit.fill,
          ),
          color: Colors.brown.shade800, // Fallback color
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black54, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Stack(
          children: [
            // Close Button (Top Right)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => setState(() => isTrayExpanded = false),
              ),
            ),

            // 50% Opacity Brown Boundary Box with Scrollbar
            Positioned(
              top: 70,
              bottom: 30,
              left: 24,
              right: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.brown.withOpacity(0.50), // 50% Brown Opacity
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black45, width: 2),
                ),
                child: Theme(
                  // Customizing the Scrollbar to look game-friendly
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbColor: MaterialStateProperty.all(
                        Colors.orangeAccent.withOpacity(0.8),
                      ),
                      thickness: MaterialStateProperty.all(8),
                      radius: const Radius.circular(10),
                      crossAxisMargin: 4,
                    ),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12.0),
                      children: [
                        // Card 1: Actual Upgrade
                        _buildCustomUpgradeCard(
                          title: "Tap Power",
                          level: viewModel.tapLevel,
                          cost: viewModel.calculateTapUpgradeCost(),
                          canAfford:
                              viewModel.joy >=
                              viewModel.calculateTapUpgradeCost(),
                          iconAsset: 'assets/images/icon_tap_power.png',
                          onTap: () => viewModel.buyTapUpgrade(),
                        ),
                        // --- ADDED: BURROW UPGRADE CARD ---
                        _buildCustomUpgradeCard(
                          title: "Burrow Upgrade",
                          level: viewModel
                              .burrowLevel, // Assuming this is your ViewModel variable
                          cost: viewModel
                              .calculateBurrowUpgradeCost(), // Assuming this is your ViewModel method
                          canAfford:
                              viewModel.joy >=
                              viewModel.calculateBurrowUpgradeCost(),
                          iconAsset:
                              'assets/images/icon_shovel.png', // Add a shovel icon to your assets!
                          onTap: () {
                            // 1. Deduct Joy and save Level 2 to the database
                            viewModel.buyBurrowUpgrade();

                            // 2. Tell the Flame engine to crumble the dirt and move the camera!
                            widget.game.unlockNextStage();

                            // (Optional) Close the tray so the player can watch the animation
                            setState(() => isTrayExpanded = false);
                          },
                        ),
                        // ----------------------------------
                        // Card 2: Dummy Upgrade (to show scroll)
                        _buildCustomUpgradeCard(
                          title: "Offline Yield",
                          level: 1,
                          cost: 150,
                          canAfford: viewModel.joy >= 150,
                          iconAsset: 'assets/images/icon_offline.png',
                          onTap: () {}, // Will implement later
                        ),
                        // Card 3: Dummy Upgrade
                        _buildCustomUpgradeCard(
                          title: "Carrot Storage",
                          level: 1,
                          cost: 300,
                          canAfford: viewModel.joy >= 300,
                          iconAsset: 'assets/images/icon_storage.png',
                          onTap: () {}, // Will implement later
                        ),
                        // Card 4: Dummy Upgrade
                        _buildCustomUpgradeCard(
                          title: "Bunny Speed",
                          level: 1,
                          cost: 500,
                          canAfford: viewModel.joy >= 500,
                          iconAsset: 'assets/images/icon_speed.png',
                          onTap: () {}, // Will implement later
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- THE CUSTOM UI CARD ---
  Widget _buildCustomUpgradeCard({
    required String title,
    required int level,
    required int cost,
    required bool canAfford,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.5),
      ),
      child: Row(
        children: [
          // Left Side: Custom Icon Box
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.brown.shade800,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orangeAccent, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(
                iconAsset,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.star, color: Colors.yellow, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Middle: Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title Lv.$level",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/icon_heart.png',
                      width: 16,
                      height: 16,
                      errorBuilder: (ctx, err, stk) => const Icon(
                        Icons.favorite,
                        color: Colors.pinkAccent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cost.toString(),
                      style: TextStyle(
                        color: canAfford ? Colors.white : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Side: Custom Chunky Game Button
          GestureDetector(
            onTap: canAfford ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: canAfford
                      ? [Colors.green.shade400, Colors.green.shade700]
                      : [Colors.grey.shade500, Colors.grey.shade800],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ), // Sharp drop shadow for chunky look
                ],
              ),
              child: const Text(
                "BUY",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- THE CURRENCY BADGES ---
  Widget _buildCurrencyBadge(
    String assetPath,
    String amount,
    Color fallbackColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.monetization_on, color: fallbackColor, size: 28),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
