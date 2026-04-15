import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ProSurvivalGame());

class ProSurvivalGame extends StatelessWidget {
  const ProSurvivalGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const GameCanvas(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameCanvas extends StatefulWidget {
  const GameCanvas({super.key});

  @override
  _GameCanvasState createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> {
  // --- Movement & Logic ---
  double ballY = -1.1;
  double ballX = 0.0;
  double paddleX = 0.0;
  double ballSpeed = 0.015;

  // --- Game Stats ---
  int score = 0;
  int lives = 5;
  int secondsPlayed = 0;

  // --- State Control ---
  bool isPlaying = false;
  bool isGameOver = false;
  Timer? gameTimer;
  Timer? playDurationTimer;

  void startGame() {
    setState(() {
      score = 0;
      lives = 5;
      secondsPlayed = 0;
      ballY = -1.1;
      ballX = (Random().nextDouble() * 2) - 1;
      ballSpeed = 0.015; // Reset to base speed
      isPlaying = true;
      isGameOver = false;
    });

    // Loop 1: Physics & Collision (Running at ~60 FPS)
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        ballY += ballSpeed;
      });

      // Catch Logic (Ball hits paddle)
      if (ballY >= 0.8 && (ballX - paddleX).abs() < 0.25) {
        score += 10;
        _resetBall();
      }

      // Miss Logic (Losing Lives)
      if (ballY > 1.1) {
        lives--;
        if (lives <= 0) {
          _endGame();
        } else {
          _resetBall();
        }
      }
    });

    // Loop 2: Play Duration Tracker & Difficulty Scaling
    playDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsPlayed++;
        // Gradually increase speed every 15 seconds to keep it challenging
        if (secondsPlayed % 15 == 0 && ballSpeed < 0.04) {
          ballSpeed += 0.003;
        }
      });
    });
  }

  void _resetBall() {
    ballY = -1.1;
    ballX = (Random().nextDouble() * 2) - 1;
  }

  void _endGame() {
    gameTimer?.cancel();
    playDurationTimer?.cancel();
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
  }

  // Helper to format raw seconds into 00:00 style
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (!isPlaying) return;
            setState(() {
              // Adjust divisor to change paddle sensitivity
              paddleX += details.delta.dx / (MediaQuery.of(context).size.width / 2);
              paddleX = paddleX.clamp(-0.85, 0.85);
            });
          },
          child: Stack(
            children: [
              // --- HUD: Stats ---
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat("SCORE", score.toString(), Colors.white),
                    _buildStat("LIVES", "❤️" * lives, Colors.redAccent),
                    _buildStat("TIME", _formatDuration(secondsPlayed), Colors.cyanAccent),
                  ],
                ),
              ),

              // --- Speed Slider (Manual override) ---
              Positioned(
                bottom: 40,
                left: 30,
                child: _buildSpeedSlider(),
              ),

              // --- The Ball ---
              if (isPlaying)
                Container(
                  alignment: Alignment(ballX, ballY),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amberAccent,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.amber.withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 2
                        ),
                      ],
                    ),
                  ),
                ),

              // --- The Paddle ---
              Container(
                alignment: Alignment(paddleX, 0.85),
                child: Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8)
                    ],
                  ),
                ),
              ),

              // --- Manual Quit Button ---
              if (isPlaying)
                Positioned(
                  top: 110,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white38),
                    onPressed: _endGame,
                  ),
                ),

              // --- Menu/Game Over Overlay ---
              if (!isPlaying) _buildMenuOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // UI Component: Menu Overlay
  Widget _buildMenuOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85), // Fixed the color error here
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isGameOver ? Icons.heart_broken_rounded : Icons.sports_esports_rounded,
            size: 80,
            color: isGameOver ? Colors.redAccent : Colors.cyanAccent,
          ),
          const SizedBox(height: 10),
          Text(
            isGameOver ? "GAME OVER" : "SURVIVAL MODE",
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          if (isGameOver) ...[
            Text("Final Score: $score", style: const TextStyle(fontSize: 24, color: Colors.amberAccent)),
            Text("Time Survived: ${_formatDuration(secondsPlayed)}", style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 40),
          ],
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: startGame,
            child: Text(
              isGameOver ? "TRY AGAIN" : "START MISSION",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // UI Component: Individual Stat item
  Widget _buildStat(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.5)),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valColor)),
      ],
    );
  }

  // UI Component: Speed Slider
  Widget _buildSpeedSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DIFFICULTY (SPEED)", style: TextStyle(fontSize: 10, color: Colors.white38)),
        SizedBox(
          width: 140,
          child: Slider(
            value: ballSpeed,
            min: 0.01,
            max: 0.04,
            activeColor: Colors.amberAccent,
            onChanged: (val) => setState(() => ballSpeed = val),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    playDurationTimer?.cancel();
    super.dispose();
  }
}










//name: falling_ball
// description: "A new Flutter project."
// # The following line prevents the package from being accidentally published to
// # pub.dev using `flutter pub publish`. This is preferred for private packages.
// publish_to: 'none' # Remove this line if you wish to publish to pub.dev
//
// # The following defines the version and build number for your application.
// # A version number is three numbers separated by dots, like 1.2.43
// # followed by an optional build number separated by a +.
// # Both the version and the builder number may be overridden in flutter
// # build by specifying --build-name and --build-number, respectively.
// # In Android, build-name is used as versionName while build-number used as versionCode.
// # Read more about Android versioning at https://developer.android.com/studio/publish/versioning
// # In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
// # Read more about iOS versioning at
// # https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
// # In Windows, build-name is used as the major, minor, and patch parts
// # of the product and file versions while build-number is used as the build suffix.
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.1
//
// # Dependencies specify other packages that your package needs in order to work.
// # To automatically upgrade your package dependencies to the latest versions
// # consider running `flutter pub upgrade --major-versions`. Alternatively,
// # dependencies can be manually updated by changing the version numbers below to
// # the latest version available on pub.dev. To see which dependencies have newer
// # versions available, run `flutter pub outdated`.
// dependencies:
//   flutter:
//     sdk: flutter
//
//   # The following adds the Cupertino Icons font to your application.
//   # Use with the CupertinoIcons class for iOS style icons.
//   cupertino_icons: ^1.0.8
//
// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//
//   # The "flutter_lints" package below contains a set of recommended lints to
//   # encourage good coding practices. The lint set provided by the package is
//   # activated in the `analysis_options.yaml` file located at the root of your
//   # package. See that file for information about deactivating specific lint
//   # rules and activating additional ones.
//   flutter_lints: ^5.0.0
//
// # For information on the generic Dart part of this file, see the
// # following page: https://dart.dev/tools/pub/pubspec
//
// # The following section is specific to Flutter packages.
// flutter:
//
//   # The following line ensures that the Material Icons font is
//   # included with your application, so that you can use the icons in
//   # the material Icons class.
//   uses-material-design: true
//
//   # To add assets to your application, add an assets section, like this:
//   # assets:
//   #   - images/a_dot_burr.jpeg
//   #   - images/a_dot_ham.jpeg
//
//   # An image asset can refer to one or more resolution-specific "variants", see
//   # https://flutter.dev/to/resolution-aware-images
//
//   # For details regarding adding assets from package dependencies, see
//   # https://flutter.dev/to/asset-from-package
//
//   # To add custom fonts to your application, add a fonts section here,
//   # in this "flutter" section. Each entry in this list should have a
//   # "family" key with the font family name, and a "fonts" key with a
//   # list giving the asset and other descriptors for the font. For
//   # example:
//   # fonts:
//   #   - family: Schyler
//   #     fonts:
//   #       - asset: fonts/Schyler-Regular.ttf
//   #       - asset: fonts/Schyler-Italic.ttf
//   #         style: italic
//   #   - family: Trajan Pro
//   #     fonts:
//   #       - asset: fonts/TrajanPro.ttf
//   #       - asset: fonts/TrajanPro_Bold.ttf
//   #         weight: 700
//   #
//   # For details regarding fonts from package dependencies,
//   # see https://flutter.dev/to/font-from-package
