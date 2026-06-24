import 'package:hive/hive.dart';

class PlayerRepository {
  final Box _box = Hive.box('playerData');

  // --- Read (Getters) ---
  int get joy => _box.get('joy', defaultValue: 0);
  int get tapLevel => _box.get('tap_level', defaultValue: 0);
  int get burrowLevel => _box.get('burrow_level', defaultValue: 1);
  int get passiveRate => _box.get('passive_rate', defaultValue: 0);

  // --- Update (Setters) ---
  void updateJoy(int value) => _box.put('joy', value);
  void updateTapLevel(int value) => _box.put('tap_level', value);
  void updateBurrowLevel(int value) => _box.put('burrow_level', value);
  void updatePassiveRate(int value) => _box.put('passive_rate', value);
  
  // --- NEW CURRENCIES ---
  int get flowers => _box.get('flowers', defaultValue: 0);
  void updateFlowers(int value) => _box.put('flowers', value);

  int get carrots => _box.get('carrots', defaultValue: 0);
  void updateCarrots(int value) => _box.put('carrots', value);
}
