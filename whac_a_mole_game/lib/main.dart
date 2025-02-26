import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:math';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WhacAMoleGame(playerPhone: "Phone3"), // Change per device
    );
  }
}

class WhacAMoleGame extends StatefulWidget {
  final String playerPhone;

  const WhacAMoleGame({super.key, required this.playerPhone});

  @override
  _WhacAMoleGameState createState() => _WhacAMoleGameState();
}

class _WhacAMoleGameState extends State<WhacAMoleGame> {
  String activePhone = "";
  int score = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listenToActivePhone();
    if (widget.playerPhone == "Phone1") {
      _startPhoneRotation(); // Only "Phone1" starts rotation
    }
  }
  void _restartGame() async {
  await FirebaseFirestore.instance.collection('game').doc('currentState').set({
    'activePhone': "Phone1", // Set an initial active phone
    'players': {
      'Phone1': {'score': 0, 'lastTapTime': 0},
      'Phone2': {'score': 0, 'lastTapTime': 0},
      'Phone3': {'score': 0, 'lastTapTime': 0},
    }
  }, SetOptions(merge: true));

  print("Game restarted!");
}

  /// Listen for active phone changes from Firestore
  void _listenToActivePhone() {
    FirebaseFirestore.instance
        .collection('game')
        .doc('currentState')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data()!;
        setState(() {
          activePhone = data['activePhone'] ?? "";
          Map<String, dynamic>? players = data['players'];
          score = players?[widget.playerPhone]?['score'] ?? 0; // Prevent crashes
        });
        print("Phone ${widget.playerPhone}: Active phone updated to $activePhone");
      }
    });
  }

  /// Changes the active phone every 2 seconds (Only handled by "Phone1")
  void _startPhoneRotation() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _changeActivePhone();
    });
  }

  /// Selects a new random phone (avoiding duplicate selection)
  void _changeActivePhone() async {
  List<String> phones = ["Phone1", "Phone2", "Phone3"];

  // Ensure the new active phone is different from the current one
  String newActivePhone;
  do {
    newActivePhone = phones[Random().nextInt(phones.length)];
  } while (newActivePhone == activePhone);

  // Atomically update Firestore to ensure only one active phone
  await FirebaseFirestore.instance
      .collection('game')
      .doc('currentState')
      .set({'activePhone': newActivePhone}, SetOptions(merge: true));
}

  /// Handles phone tap and updates Firestore score
  void _onPhoneTapped() async {
    if (widget.playerPhone == activePhone) {
      setState(() {
        score += 1;
      });

      await FirebaseFirestore.instance
          .collection('game')
          .doc('currentState')
          .update({
        'players.${widget.playerPhone}.score': score,
        'players.${widget.playerPhone}.lastTapTime': DateTime.now().millisecondsSinceEpoch,
      });

      print("Correct tap! +1 point");
    } else {
      print("Wrong phone tapped!");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("${widget.playerPhone}: Rebuilding UI. Active Phone: $activePhone");
    Color backgroundColor = (activePhone == widget.playerPhone) ? Colors.green : Colors.red;
    return GestureDetector(
      onTap: _onPhoneTapped, 
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(title: Text("Whac-A-Mole")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Active Phone: $activePhone", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              Text("Your Score: $score", style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              if (widget.playerPhone == "Phone1") 
                ElevatedButton(
                  onPressed: _restartGame,
                  child: Text("Restart Game"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}