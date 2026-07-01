enum BunnyBreed { americanfuzzylop, hollandlop, lop }

// This extension acts like a configuration file for your breeds
extension BunnyBreedData on BunnyBreed {
  int get idleFrameCount {
    switch (this) {
      case BunnyBreed.americanfuzzylop:
        return 5; // has 5 frames for idle
      case BunnyBreed.hollandlop:
        return 5; // has 5 frames for idle
      case BunnyBreed.lop:
        return 5; // Lop bunny has 5 frames for idle
    }
  }

  int get hoppingFrameCount {
    switch (this) {
      case BunnyBreed.americanfuzzylop:
        return 6;
      case BunnyBreed.hollandlop:
        return 5;
      case BunnyBreed.lop:
        return 5;
    }
  }

  // You can even add custom speeds for different breeds!
  double get speed {
    switch (this) {
      case BunnyBreed.americanfuzzylop:
        return 30.0; // Normal
      case BunnyBreed.hollandlop:
        return 45.0; // Fast
      case BunnyBreed.lop:
        return 20.0; // Slow and sleepy
    }
  }
}
