import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:bunny_burrow/repositories/player_repository.dart';
import 'package:bunny_burrow/viewmodels/game_viewmodel.dart';

void main() {
  // We declare these here so all tests can use them
  late PlayerRepository repository;
  late GameViewModel viewModel;

  // The setUp() function runs BEFORE every single test.
  // We use it to create a temporary, clean database so our tests don't mess up your real save file!
  setUp(() async {
    // Create a temporary folder for Hive to use during the test
    final path = Directory.systemTemp.createTempSync().path;
    Hive.init(path);

    // Open a fresh box and clear any old test data
    final box = await Hive.openBox('playerData');
    await box.clear();

    // Initialize our MVVM architecture
    repository = PlayerRepository();
    viewModel = GameViewModel(repository);
  });

  // Clean up after the tests are done
  tearDown(() async {
    await Hive.close();
  });

  group('GameViewModel Unit Tests', () {
    test('addJoy adds the correct amount of currency to the player state', () {
      // --- ARRANGE ---
      // We ensure the starting joy is exactly 0
      expect(viewModel.joy, equals(0));
      final int amountToAdd = 15;

      // --- ACT ---
      // We call the function we want to test
      viewModel.addJoy(amountToAdd);

      // --- ASSERT ---
      // We verify the outcome matches our expectations
      expect(viewModel.joy, equals(15));
    });

    test('calculateTapUpgradeCost returns correct exponential math', () {
      // --- ARRANGE ---
      // Base cost is 10. Formula is (10 * 1.15^tapLevel)
      // We manually set the tap level to 2 for this test
      repository.updateTapLevel(2);

      // --- ACT ---
      final int calculatedCost = viewModel.calculateTapUpgradeCost();

      // --- ASSERT ---
      // 10 * (1.15 * 1.15) = 13.225. We expect it to floor to 13.
      expect(calculatedCost, equals(13));
    });

    test('buyTapUpgrade deducts Joy and increases Tap Level if affordable', () {
      // --- ARRANGE ---
      // Give the player exactly enough Joy to buy Level 1 (Cost: 10)
      viewModel.addJoy(10);
      expect(viewModel.tapLevel, equals(0)); // Starting level
      expect(viewModel.joy, equals(10)); // Starting money

      // --- ACT ---
      // Attempt to purchase the upgrade
      viewModel.buyTapUpgrade();

      // --- ASSERT ---
      // Joy should be deducted (10 - 10 = 0)
      expect(viewModel.joy, equals(0));
      // Tap Level should be increased (0 + 1 = 1)
      expect(viewModel.tapLevel, equals(1));
    });

    test(
      'buyTapUpgrade fails and changes nothing if player cannot afford it',
      () {
        // --- ARRANGE ---
        // Give the player 5 Joy (Cost for level 1 is 10)
        viewModel.addJoy(5);

        // --- ACT ---
        viewModel.buyTapUpgrade();

        // --- ASSERT ---
        // Joy should NOT be deducted, Level should NOT increase
        expect(viewModel.joy, equals(5));
        expect(viewModel.tapLevel, equals(0));
      },
    );
  });
}
