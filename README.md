#  Whac-A-Mole Game (Flutter + Firebase)

A fun, real-time Whac-A-Mole style game played across **three physical phones** using **Flutter** and **Firebase Firestore** for synchronization.

## Gameplay Overview

- Three phones are connected via the same Firebase project.
- One phone lights up **green** (full screen) — this is the target.
- The other two phones light up **red**.
- Every **1–3 seconds**, the green target randomly switches to a different phone.
- The player must **tap the green phone** to earn a point before the next switch.

## Features

- Real-time color updates using **Firebase Firestore**
-  Randomized timing and phone selection
-  Score tracking for correct taps
-  Smooth, responsive UI using **Flutter**

## Tech Stack

- **Flutter** (Frontend)
- **Firebase Firestore** (Real-time Sync)
- **Dart** (Programming Language)

  


## Installation

1. **Clone the repo**:
   git clone https://github.com/your-username/whac-a-mole-flutter.git
   cd whac-a-mole-flutter
   
2. **Install dependencies**:
flutter pub get

3. **Set up Firebase**:
- Create a Firebase project.
- Enable Firestore.
- Download google-services.json (Android) or GoogleService-Info.plist (iOS).
-Place it in the appropriate android/app or ios/Runner directory.

4. **Initialize Firebase in code: Make sure your main.dart contains Firebase initialization.**

5. **Run the app on three physical phones (or emulators)**

## Credits
Made using Flutter & Firebase by Lisandra Williams.
