import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TapGameApp());
}

class TapGameApp extends StatelessWidget {
  const TapGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
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
  // Game Variables
  int _score = 0;
  int _timeLeft = 30; // 30 second game
  bool _isGameRunning = false;

  double _posX = 100.0;
  double _posY = 100.0;
  final double _circleSize = 60.0;

  Timer? _timer;
  final Random _random = Random();

  // Function to move the circle to a random position
  void _moveCircle() {
    // Get screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calculate safe bounds (subtracting circle size and app bar/padding)
    setState(() {
      _posX = _random.nextDouble() * (screenWidth - _circleSize);
      _posY = _random.nextDouble() * (screenHeight - _circleSize - 150);
    });
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isGameRunning = true;
    });
    _moveCircle();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _handleTap() {
    if (_isGameRunning) {
      setState(() => _score++);
      _moveCircle();
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _isGameRunning = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Over!"),
        content: Text("You scored $_score points."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text("Play Again"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Circle Tapper 2D"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Score and Timer Display
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoPanel("Score", _score.toString(), Colors.blue),
                _infoPanel("Time", "${_timeLeft}s", _timeLeft < 10 ? Colors.red : Colors.orange),
              ],
            ),
          ),

          // Game Area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: Stack(
                children: [
                  if (!_isGameRunning)
                    Center(
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
                        child: const Text("START GAME", style: TextStyle(fontSize: 20)),
                      ),
                    ),

                  if (_isGameRunning)
                    Positioned(
                      left: _posX,
                      top: _posY,
                      child: GestureDetector(
                        onTap: _handleTap,
                        child: Container(
                          width: _circleSize,
                          height: _circleSize,
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPanel(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}









//name: tap_game
// description: "A simple 2D circle tapping game"
// publish_to: 'none'
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.0
//
// dependencies:
//   flutter:
//     sdk: flutter
//
// flutter:
//   uses-material-design: true
