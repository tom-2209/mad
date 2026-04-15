import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ColorMatchApp());
}

class ColorMatchApp extends StatelessWidget {
  const ColorMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Color Match Game',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();

  Color targetColor = Colors.red;
  Color playerColor = Colors.blue;

  int score = 0;

  // ⏱️ TIMER VARIABLES
  int timeLeft = 30;
  Timer? gameTimer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  // ⏳ START TIMER
  void startTimer() {
    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          isGameOver = true;
          timer.cancel();
        }
      });
    });
  }

  // 🎨 RANDOM COLOR
  Color getRandomColor() {
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // 🎮 TAP ACTION
  void changePlayerColor() {
    if (isGameOver) return; // 🚫 stop after game ends

    setState(() {
      playerColor = getRandomColor();

      if (isMatch(targetColor, playerColor)) {
        score++;
        targetColor = getRandomColor();
      }
    });
  }

  // ✅ MATCH LOGIC
  bool isMatch(Color a, Color b) {
    int tolerance = 40;

    return (a.red - b.red).abs() < tolerance &&
        (a.green - b.green).abs() < tolerance &&
        (a.blue - b.blue).abs() < tolerance;
  }

  // 🔄 RESET GAME
  void resetGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isGameOver = false;
      targetColor = getRandomColor();
      playerColor = getRandomColor();
    });

    startTimer();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Color Match Game"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // ⏱️ TIMER DISPLAY
          Text(
            "Time Left: $timeLeft s",
            style: const TextStyle(fontSize: 22, color: Colors.orange),
          ),

          const SizedBox(height: 10),

          // SCORE
          Text(
            "Score: $score",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          const Text("Target Color"),
          const SizedBox(height: 10),

          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: targetColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 40),

          const Text("Tap to Match"),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: changePlayerColor,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutBack,
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                color: playerColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: playerColor.withOpacity(0.6),
                    blurRadius: 20,
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 🛑 GAME OVER TEXT
          if (isGameOver)
            const Text(
              "⛔ Game Over!",
              style: TextStyle(fontSize: 24, color: Colors.red),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: resetGame,
            child: const Text("Restart Game"),
          )
        ],
      ),
    );
  }
}

/*
pubspec.yaml
name: color_match_game
description: A gesture-based color matching game

environment:
  sdk: ">=2.19.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

flutter:
  uses-material-design: true
 */