import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MoodApp());
}

class MoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MoodHome(),
    );
  }
}

class Mood {
  final String name;
  final String emoji;
  final Color color;

  Mood(this.name, this.emoji, this.color);
}

class MoodHome extends StatefulWidget {
  @override
  _MoodHomeState createState() => _MoodHomeState();
}

class _MoodHomeState extends State<MoodHome> {
  List<Mood> moods = [
    Mood("Happy", "😄", Colors.yellow),
    Mood("Sad", "😢", Colors.blue),
    Mood("Angry", "😡", Colors.red),
    Mood("Relaxed", "😌", Colors.green),
    Mood("Excited", "🤩", Colors.orange),
  ];

  List<String> weeklyMoods = [];

  Color bgColor = Colors.white;

  void selectMood(Mood mood) {
    setState(() {
      bgColor = mood.color.withOpacity(0.3);

      if (weeklyMoods.length == 7) {
        weeklyMoods.removeAt(0);
      }
      weeklyMoods.add(mood.name);
    });
  }

  String getMostFrequentMood() {
    if (weeklyMoods.isEmpty) return "None";

    Map<String, int> count = {};

    for (var mood in weeklyMoods) {
      count[mood] = (count[mood] ?? 0) + 1;
    }

    String maxMood = weeklyMoods[0];
    int maxCount = 0;

    count.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        maxMood = key;
      }
    });

    return maxMood;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Mood Tracker",
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "How are you feeling today?",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            /// Mood Buttons
            Wrap(
              spacing: 15,
              children: moods.map((mood) {
                return GestureDetector(
                  onTap: () => selectMood(mood),
                  child: Column(
                    children: [
                      Text(
                        mood.emoji,
                        style: TextStyle(fontSize: 35),
                      ),
                      Text(mood.name),
                    ],
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 30),

            /// Weekly Analysis
            Text(
              "Weekly Mood Analysis",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.grey.shade300,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Last 7 Days:",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    children: weeklyMoods.map((m) {
                      return Chip(label: Text(m));
                    }).toList(),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Most Frequent Mood:",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    getMostFrequentMood(),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*pubspec.yaml file
name: mood_tracker
description: A simple mood tracker app

environment:
sdk: ">=2.17.0 <4.0.0"

dependencies:
flutter:
sdk: flutter

google_fonts: ^6.1.0

flutter:
uses-material-design: true */


