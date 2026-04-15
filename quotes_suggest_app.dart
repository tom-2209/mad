import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MoodQuotesApp());
}

class MoodQuotesApp extends StatelessWidget {
  const MoodQuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Quotes',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String quote = "Select your mood to get inspired";
  String author = "";
  bool isLoading = false;
  Color bgColor = Colors.orange.shade100;

  final Map<String, List<Map<String, String>>> localQuotes = {
    "happy": [
      {"q": "Happiness is a choice.", "a": "Unknown"},
      {"q": "Smile, it's free therapy.", "a": "Douglas Horton"},
    ],
    "sad": [
      {"q": "This too shall pass.", "a": "Persian Proverb"},
      {"q": "Tough times never last.", "a": "Robert Schuller"},
    ],
    "motivational": [
      {"q": "Push yourself, no one else will.", "a": "Unknown"},
      {"q": "Dream big. Start small.", "a": "Simon Sinek"},
    ],
    "calm": [
      {"q": "Peace begins with a smile.", "a": "Mother Teresa"},
      {"q": "Stay calm and carry on.", "a": "Unknown"},
    ],
  };

  Future<void> fetchQuote(String mood) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            "https://api.allorigins.win/raw?url=https://zenquotes.io/api/random"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          quote = data[0]['q'];
          author = data[0]['a'];
        });
      } else {
        useLocalQuote(mood);
      }
    } catch (e) {
      useLocalQuote(mood);
    }

    setState(() {
      isLoading = false;
    });
  }

  void useLocalQuote(String mood) {
    final random = Random();
    final list = localQuotes[mood]!;
    final item = list[random.nextInt(list.length)];

    setState(() {
      quote = item['q']!;
      author = item['a']!;
    });
  }

  void setMood(String mood) {
    switch (mood) {
      case "happy":
        bgColor = Colors.orange.shade100;
        break;
      case "sad":
        bgColor = Colors.blue.shade100;
        break;
      case "motivational":
        bgColor = Colors.red.shade100;
        break;
      case "calm":
        bgColor = Colors.teal.shade100;
        break;
    }

    fetchQuote(mood);
  }

  Widget moodButton(String mood, Color color) {
    return GestureDetector(
      onTap: () => setMood(mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 3),
            )
          ],
        ),
        child: Text(
          mood.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Mood Quotes App"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                moodButton("happy", Colors.orange),
                moodButton("sad", Colors.blue),
                moodButton("motivational", Colors.red),
                moodButton("calm", Colors.teal),
              ],
            ),

            const SizedBox(height: 40),

            isLoading
                ? const CircularProgressIndicator()
                : Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Text(
                      "\"$quote\"",
                      style: const TextStyle(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "- $author",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => fetchQuote("motivational"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
              ),
              child: const Text("New Quote"),
            ),
          ],
        ),
      ),
    );
  }
}

/*
name: untitled3
description: Mood Quotes App

publish_to: 'none'

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1

flutter:
  uses-material-design: true
 */