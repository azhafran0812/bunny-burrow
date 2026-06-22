# Bunny Burrow 🐰 (MVVM Architecture)

## 1. Architectural Overview
Bunny Burrow is an interactive, offline-first idle game built with Flutter and Flame. To fulfill the assignment requirements, this project implements the **MVVM (Model-View-ViewModel)** design pattern. This ensures a strict separation of concerns, resolving the issue of the Flame 2D game loop and the Flutter UI tightly coupling to local database queries.

* **Model (Data & Repository):** The `PlayerRepository` class encapsulates all logic related to the `Hive` local database. It performs all CRUD operations (saving Joy, tracking burrow levels) and acts as the single source of truth for the raw data.
* **ViewModel:** The `GameViewModel` extends `ChangeNotifier`. It acts as the bridge between the Repository and the Views. It handles all business and mathematical logic (e.g., calculating exponential upgrade costs, processing purchases). It uses `notifyListeners()` to broadcast state changes.
* **View (UI):** The standard Flutter overlays (`HudOverlay`, `UpgradeOverlay`) utilize the `Consumer` widget from the `provider` package. They listen exclusively to the `GameViewModel` and automatically rebuild when data changes, completely ignorant of the underlying database.

## 2. Instructions to Run
1. Ensure you have the Flutter SDK installed on your machine.
2. Clone this repository locally.
3. Open a terminal in the project root and run `flutter pub get` to download required dependencies (`flame`, `hive`, `provider`).
4. Run `flutter run` to launch the application on an emulator or connected device.
*(Note: If testing via a desktop web browser emulator like Edge/Chrome, use your mouse scroll wheel to drag the camera down into the expanded grid).*

## 3. Personal Reflection/Evaluation
ENG:
Transitioning *Bunny Burrow* to the MVVM pattern was challenging but fundamentally changed how I view state management. Initially, my Flame components and Flutter widgets were directly querying the Hive database, making the code messy and hard to debug. Extracting the data into a `PlayerRepository` and wrapping it in a `ChangeNotifier` ViewModel solved this. 

The biggest technical challenge I faced was bridging standard Flutter State Management with the Flame Game Engine, as Flame exists outside the normal Flutter widget tree. I solved this by wrapping my entire `MaterialApp` in a `ChangeNotifierProvider`, and then passing the initialized `GameViewModel` directly into the `BunnyGame` constructor. This allowed my interactive elements (like the Ancestor Carrot) to trigger logic in the same exact ViewModel that my UI `Consumer` widgets were listening to. This assignment greatly solidified my understanding of scalable architectural design.

IN:
Mentransisikan Bunny Burrow ke pola MVVM merupakan tantangan yang cukup besar, tetapi pengalaman tersebut secara fundamental mengubah cara saya memandang manajemen state. Pada awalnya, komponen Flame dan widget Flutter saya langsung mengakses database Hive, sehingga kode menjadi berantakan dan sulit untuk di-debug. Saya kemudian memisahkan akses data ke dalam PlayerRepository dan membungkusnya dengan ViewModel berbasis ChangeNotifier, yang berhasil menyelesaikan masalah tersebut.

Tantangan teknis terbesar yang saya hadapi adalah menjembatani State Management standar Flutter dengan Game Engine Flame, karena Flame berjalan di luar struktur widget tree Flutter yang normal. Saya mengatasinya dengan membungkus seluruh MaterialApp menggunakan ChangeNotifierProvider, lalu meneruskan GameViewModel yang telah diinisialisasi langsung ke konstruktor BunnyGame. Dengan pendekatan ini, elemen interaktif dalam game (seperti Ancestor Carrot) dapat memicu logika pada ViewModel yang sama persis dengan yang dipantau oleh widget Consumer pada antarmuka pengguna. Tugas ini sangat memperkuat pemahaman saya tentang perancangan arsitektur aplikasi yang skalabel dan mudah dipelihara.

## AFL 3: Unit Testing Implementation

**Chosen Functionality:** For the unit testing assignment, I chose to test the core progression math and shop logic located in the `GameViewModel` class.

**Logic Being Tested:** The tests evaluate the isolated business logic responsible for the in-game economy. Specifically, it tests:
1. State manipulation (`addJoy`), ensuring currency correctly updates the local repository.
2. Mathematical calculations (`calculateTapUpgradeCost`), verifying that the exponential cost scaling formula accurately calculates upcoming upgrade prices based on the player's current level.
3. Conditional logic (`buyTapUpgrade`), ensuring that transactions only process if the player has sufficient funds, and that currency deductions and level increments happen synchronously.

Because this application uses the MVVM design pattern, I was able to test this logic in complete isolation without needing to spin up the Flutter UI or the Flame Game Engine. The tests strictly follow the **Arrange-Act-Assert (AAA)** pattern to ensure clear, maintainable, and highly readable test coverage.