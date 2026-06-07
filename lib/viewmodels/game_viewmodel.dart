import 'dart:math';
import 'package:flutter/material.dart';
import '../repositories/player_repository.dart';

// ChangeNotifier is what allows Provider to magically update your UI
class GameViewModel extends ChangeNotifier {
  final PlayerRepository _repository;

  // The ViewModel requires the repository to be passed in when created
  GameViewModel(this._repository);

  // --- 1. Expose Data to the Views ---
  int get joy => _repository.joy;
  int get tapLevel => _repository.tapLevel;
  int get burrowLevel => _repository.burrowLevel;
  int get passiveRate => _repository.passiveRate;

  // --- 2. Core Business Logic ---

  void addJoy(int amount) {
    _repository.updateJoy(joy + amount);
    notifyListeners(); // This single line tells the UI to rebuild instantly!
  }

  void spendJoy(int amount) {
    if (joy >= amount) {
      _repository.updateJoy(joy - amount);
      notifyListeners();
    }
  }

  // --- 3. Shop & Upgrade Logic ---

  int calculateTapUpgradeCost() {
    int baseCost = 10;
    double costMultiplier = 1.15;
    return (baseCost * pow(costMultiplier, tapLevel)).toInt();
  }

  void buyTapUpgrade() {
    int cost = calculateTapUpgradeCost();
    if (joy >= cost) {
      spendJoy(cost);
      _repository.updateTapLevel(tapLevel + 1);
      notifyListeners();
    }
  }

  int get expansionCost => burrowLevel == 1 ? 500 : 5000;

  bool buyBurrowExpansion() {
    if (joy >= expansionCost && burrowLevel < 3) {
      spendJoy(expansionCost);
      _repository.updateBurrowLevel(burrowLevel + 1);
      notifyListeners();
      return true; // Returns true so the Flame Engine knows to crumble the dirt
    }
    return false;
  }
}